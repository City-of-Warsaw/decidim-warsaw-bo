# frozen_string_literal: true

module Decidim
  module Projects
    # Custom helpers, scoped to the projects engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::MapHelper
      include Decidim::Projects::MapHelper
      include Decidim::Projects::SharedHelper

      def text_editor_for_project_body(form, ops = {})
        options = ops.merge({
                              class: "js-hashtags",
                              hashtaggable: true
                            })

        text_editor_for(form, :body, options)
      end

      def map_different_attr_name(attribute)
        case attribute
        when 'category_ids'
          'categories'
        when 'potential_recipient_ids'
          'recipients'
        when 'scope_id'
          'scope'
        else
          attribute
        end
      end

      def show_project_data(project, attribute, attachment_type = '')
        attr = map_different_attr_name(attribute)
        data = project.send(attr)
        return 'brak informacji' if (data.nil? || data.blank?) && attribute == 'universal_design'
        return '' if (data.nil? || data.blank?) && !['categories', 'recipients'].include?(attr)

        if data.is_a?(Hash)
          translated_attribute(data)
        elsif data.is_a?(TrueClass) || data.is_a?(FalseClass)
          t(data, scope: 'booleans')
        elsif data.is_a?(Integer) || data.is_a?(BigDecimal)
          budget_to_currency data
        elsif data.is_a?(Decidim::Scope)
          data.scope_with_type
        elsif attachment_type.present? || data.is_a?(Decidim::Attachment)
          mapped = data.where(attachment_type: attachment_type, temporary_file: false).map do |a|
            content_tag :li do
              translated_attribute(a.title)
            end
          end
          if mapped.any?
            content_tag :ul do
              mapped.join('').html_safe
            end
          else
            ''
          end
        elsif data.is_a?(ActiveRecord::Associations::CollectionProxy)
          # recipients & categories
          mapped = data.map do |el|
            name = el.respond_to?(:name) ? :name : :title
            content_tag :li do
              el.send(name).is_a?(Hash) ? translated_attribute(el.send(name)) : el.send(name)
            end
          end
          if project.respond_to?("custom_#{attr}")
            project.send("custom_#{attr}").split(',').each do |el|
              mapped << content_tag(:li) do
                el
              end
            end
          end
          content_tag :ul do
            mapped.join('').html_safe
          end
        elsif ['male', 'female'].include? data
          t(data, scope: 'decidim.users.gender')
        else
          data
        end
      end

      # return translation for gender
      # used for User and Project
      def gender_for(object, default = '')
        # if gender is "" it raise error
        I18n.t(object&.gender.presence || nil, scope: 'decidim.users.gender', default: default)
      end

      def render_project_body(project)
        simple_format decidim_sanitize(project.body)
      end

      def show_explanation(attribute)
        t(attribute, scope: 'decidim.projects.projects.form_fields.explanations', default: '')
      end

      def budget_to_currency(budget)
        number_to_currency budget, unit: Decidim.currency_unit, precision: 2, strip_insignificant_zeros: false
      end

      def filter_projects_state_values
        Decidim::Projects::Project.const_get(:STATES_FOR_SEARCH).map do |st|
          label = st == 'published' ? published_status_translation : st
          [t(label, scope: 'decidim.admin.filters.projects.state_eq.values'), st]
        end
      end

      # public method
      # returns proper translation for status published in accordance to ACTUAL EDITION
      def published_status_translation
        step = Decidim::ParticipatoryProcess.actual_edition&.active_step
        step && step.end_date < DateTime.current ? 'evaluation' : 'submited'
      end

      def conversation_with_author(project)
        classes = "button hollow expanded button--sc"
        author = project.creator_author
        return unless author
        return if current_user == author
        return unless author.allow_private_message?

        if author.email && (!author.show_my_name || !author.accepts_conversation?(current_user) || !current_user)
          # if author gave hie email but:
          # - is anonymized OR
          # - does not accept conversations OR
          # - or there is no current user
          url = ''
          classes += ' sending-private-email-js'
        elsif project.creator_author.accepts_conversation?(current_user)
          url = current_or_new_conversation_path_with(project.creator_author)
        else
          return
        end

        link_to t("write_to_author", scope: 'decidim.projects.projects.show'), url, class: classes
      end

      def sending_message_modal_translation(project)
        if !project.creator_author.email
          # only simple user without email
          '.simple_user'
        elsif !project.creator_author.accepts_conversation?(current_user)
          '.user_is_not_receiving_messages'
        else
          if current_user
            '.error'
          else
            ".account_message"
          end
        end
      end

      def filter_projects_implementation_state_values
        [
          [t('in_progress', scope: 'decidim.admin.filters.projects.implementation_state_eq.values'), 'in_progress'],
          [t('finished', scope: 'decidim.admin.filters.projects.implementation_state_eq.values'), 'finished'],
          [t('abandoned', scope: 'decidim.admin.filters.projects.implementation_state_eq.values'), 'abandoned']
        ]
      end

      def filter_projects_result_state_values
        [
          [t('selected', scope: 'decidim.admin.filters.projects.state_eq.values'), 'selected'],
          [t('not_selected', scope: 'decidim.admin.filters.projects.state_eq.values'), 'not_selected']
        ]
      end

      def filter_scopes_values
        Decidim::Projects::DistrictScopes.new.query.where(decidim_organization_id: current_organization.id).map { |s| [translated_attribute(s.name), s.id] }
      end

      def filter_scope_types_values
        Decidim::ScopeType.where(decidim_organization_id: current_organization.id).map { |scope_type| [translated_attribute(scope_type.name), scope_type.id] }
      end

      def filter_categories_values
        Decidim::Area.where(decidim_organization_id: current_organization.id).map { |cat| [translated_attribute(cat.name), cat.id] }.sort { |a, b| a[0] <=> b[0] }
      end

      def filter_potential_recipients_values
        Decidim::AdminExtended::Recipient.sorted_by_name.map { |rec| [rec.name, rec.id] }
      end

      def filter_year_values(action_name)
        case action_name
        when 'realizations'
          year = Date.current.year # actual year from 1 january
          Decidim::ParticipatoryProcess.published.where("edition_year <= ?", year).order(edition_year: :desc).map(&:edition_year).uniq
        when 'results'
          show_actual_edition = Current.actual_edition.show_voting_results_button_at && Current.actual_edition.show_voting_results_button_at >= DateTime.current
          if show_actual_edition
            year = Current.actual_edition&.edition_year.presence || (Date.current + 1.year).year
            Decidim::ParticipatoryProcess.published.where("edition_year < ?", year).order(edition_year: :desc).map(&:edition_year).uniq
          else
            Decidim::ParticipatoryProcess.published.order(edition_year: :desc).map(&:edition_year).uniq
          end
        else
          Decidim::ParticipatoryProcess.published.order(edition_year: :desc).map(&:edition_year).uniq
        end
      rescue
        Decidim::ParticipatoryProcess.published.order(edition_year: :desc).map(&:edition_year).uniq
      end

      def paginated_results_count(elements_count, page = 1, per_page = 30)
        max = (page.to_i * per_page.to_i) > elements_count ? elements_count : page.to_i * per_page.to_i
        content_tag :div, class: 'text-center pagination-stats' do
          "#{((page.to_i - 1) * per_page.to_i) + 1 } - #{max} z #{elements_count} wyników"
        end
      end

      # return pagination info for Kaminari
      def paginated_counter(paginated_collection)
        return content_tag( :div, "brak wyników", class: 'text-center pagination-stats') if paginated_collection.total_count.zero?

        if paginated_collection.last_page? || paginated_collection.out_of_range?
          # ostatnia strona lub poza zakresem
          from = (paginated_collection.total_pages - 1) * paginated_collection.limit_value + 1
          to = paginated_collection.total_count
        else
          # pierwsza lub gdzies w srodku
          from = (paginated_collection.current_page - 1) * paginated_collection.limit_value + 1
          to = paginated_collection.count + (paginated_collection.current_page - 1) * paginated_collection.limit_value
        end
        msg = "#{from} - #{to} z #{paginated_collection.total_count} wyników"

        content_tag(:div, msg, class: 'text-center pagination-stats')
      end
    end
  end
end
