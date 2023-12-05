# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Helper class for Votes in admin panel.
      module VotesCardsHelper

        def list_of_warnings(list)
          content_tag('span', class: 'text-alert') do
            content_tag('ul') do
              list.each do |warning|
                concat content_tag('li', warning.is_a?(Array) ? warning[1] : warning)
              end
            end
          end.html_safe
        end

        def ip_number_info(vote)
          vote.is_paper? ? 'Wprowadzone przez Urząd' : vote.ip_number.presence || '-'
        end

        def vote_status(vote)
          I18n.t(vote.status, scope: 'decidim.admin.filters.votes.status_eq.values')
        end

        def yes_or_no_icon(val)
          icon_name = val ? 'circle-check' : 'circle-x'
          class_name = val ? 'text-success' : 'text-alert'
          icon(icon_name, class: class_name)
        end

        def stats_timetable(stat)
          views_list = %w[first_view_entering_time second_view_entering_time third_view_entering_time fourth_view_entering_time fifth_view_entering_time finished_voting_time]
          finished_voting_time = stat.finished_voting_time
          content_tag('span') do
            content_tag('ul', class: 'text-left') do
              stat.voting_timetable.each do |k, v|
                key, value = v.map { |k, vv| [k, vv] }.first
                unless stat.voting_timetable[(k.to_i + 1).to_s].nil?
                  next_key, next_value = stat.voting_timetable[(k.to_i + 1).to_s].map { |k, v| [k, v] }.first
                end

                concat content_tag(
                         'li',
                         (content_tag('strong', "#{t(key, scope: 'activemodel.attributes.vote_statistic')}:", style: 'display: block') +
                           # concat_two_dates(stat.send(li), stat.send(views_list[i + 1]), finished_voting_time))
                           if !next_value.nil?
                             "#{l value.to_time, format: :decidim_long} - #{l next_value.to_time, format: :decidim_long}"
                             # time_between_date(value.to_time, next_value.to_time)
                           else
                             "#{l value.to_time, format: :decidim_long}"
                           end
                         )
                       )
              end
            end
          end.html_safe
        end

        def time_between_date(from_date, to_date)
          seconds = ((to_date.to_time - from_date.to_time) / 1.second).round
          hours = seconds / 3600
          seconds -= hours * 3600
          minutes = seconds / 60
          seconds -= minutes * 60
          time_to_text = ''
          time_to_text += "#{hours} godzin " if hours.positive?
          time_to_text += "#{minutes} minut " if minutes.positive?
          time_to_text += "#{seconds} sekund" if seconds.positive?
          time_to_text
        end

        def concat_two_dates(date_one, date_two, final_date)
          end_time = date_two.presence || final_date

          if date_one.present?
            "#{l date_one, format: :decidim_long} - #{l end_time, format: :decidim_long}"
          else
            'Nie zarejestrowano'
          end
        end

        # list of all filtered columns on votes list
        def columns_for_selection
          %i[
            card_number is_paper pesel_number status email first_name last_name
            created_at updated_at author ip_number
          ]
        end

        def selected_columns
          params[:selected_columns]
        end

        # All columns should be showed/selected if none has been selected
        def column_selected?(column_name)
          params[:selected_columns].blank? || params[:selected_columns] && params[:selected_columns][column_name.to_s]
        end

        # show table header with link to sort votes if column is selected
        def sort_column_link(column_name, options = {})
          return unless column_selected?(column_name)

          tag.th sort_link(query, column_name, t("models.votes.fields.#{column_name}", scope: 'decidim.projects'), options)
        end
      end
    end
  end
end
