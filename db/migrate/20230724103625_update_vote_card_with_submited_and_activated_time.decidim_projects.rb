# frozen_string_literal: true

# This migration comes from decidim_projects (originally 20230724102606)

class UpdateVoteCardWithSubmitedAndActivatedTime < ActiveRecord::Migration[5.2]
  def change
    if Rails.env.development?
      Decidim::Projects::VoteCard.find_each do |vote_card|
        finished_datetime = if vote_card.is_paper
                              vote_card.publication_time.present? ? vote_card.publication_time : nil
                            else
                              vote_card.statistics.map do |statistic|
                                next unless statistic&.voting_timetable&.any?

                                if statistic&.voting_timetable.values.map { |d| d.include?('step_6') }.select { |e| e }.present?
                                  statistic.finished_voting_time
                                end
                              end.compact
                            end
        finish_datetime = Array.wrap(finished_datetime).first
        statistic = vote_card.statistics.order(created_at: :asc)&.first
        activate_time = if statistic&.voting_timetable&.any? && statistic.voting_timetable['0'].include?('step_1')
                          DateTime.parse(statistic.voting_timetable['0']['step_1'])
                        end
        vote_card.update_columns(submitted_at: finish_datetime, activated_at: activate_time)
      end
    end
  end
end
