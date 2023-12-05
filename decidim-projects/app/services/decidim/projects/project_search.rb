# frozen_string_literal: true

module Decidim
  module Projects
    # ProjectSearch handles searching and filtering projects on public views
    class ProjectSearch < ResourceSearch
      text_search_fields :title, :body, :short_description, :universal_design_argumentation, :justification_info,
                         :custom_categories, :custom_recipients, :localization_info, :localization_additional_info

      # Public: Initializes the service.
      # options     - Hash of search options
      def initialize(options = {})
        scope = options.fetch(:scope, Decidim::Projects::Project.published)
        super(scope, options)
      end

      # Public: basic query
      #
      # Returns collection of published Projects
      def base_query
        @scope.published
      end

      # Public: method search project for given phrase in a variable @search_text
      def search_search_text
        return query unless self.class.text_search_fields.any?

        text_query = query.where("decidim_projects_projects.title ILIKE :text", text: "%#{search_text}%")
                          .or(query.where("decidim_projects_projects.body ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.short_description ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.universal_design_argumentation ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.justification_info ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.custom_categories ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.custom_recipients ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.localization_info ILIKE :text", text: "%#{search_text}%"))
                          .or(query.where("decidim_projects_projects.localization_additional_info ILIKE :text", text: "%#{search_text}%"))


        text_query = text_query.or(query.where("decidim_projects_projects.esog_number": search_text.to_i)) if search_text.to_i != 0
        text_query = text_query.or(query.where("decidim_projects_projects.voting_number": search_text.to_i)) if search_text.to_i != 0
        text_query
      end

      # Public: method searches for projects with state given in potions[:state]
      #
      # For states like 'accepted' and 'rejected' search is made only for projects form spaces
      # that allows showing results
      #
      # returns query
      def search_state
        return query if options[:state].blank?

        # before evaluation_publish_date
        if options[:state].include?('rejected') || options[:state].include?('accepted')
          if DateTime.current <= Current.actual_edition.evaluation_publish_date
            temp_query = query.joins(:component => :process)
            # for editions where evaluations was revealed - only historical editions, all statuses
            returned_query = temp_query.where('decidim_projects_projects.state': options[:state])
                                       .where('decidim_participatory_processes.evaluation_publish_date <= ?', DateTime.current)
            actual_edition_states = options[:state].reject{ |n| n.in?(['accepted', 'rejected']) }
            # for current edition without accepted and rejected states
            returned_query = returned_query.or(temp_query.where('decidim_projects_projects.state': actual_edition_states)
                                                         .where('decidim_participatory_processes.evaluation_publish_date > ?', Date.current))
          elsif DateTime.current < Current.actual_edition.reevaluation_publish_date
            temp_query = query.joins(:component => :process).left_joins(:reevaluation)
            # for editions where reevaluations was revealed - only historical editions
            # accepted and rejected
            returned_query = temp_query.where('decidim_projects_projects.state': options[:state])
                                       .where('decidim_participatory_processes.reevaluation_publish_date <= ?', DateTime.current)

            if options[:state].include?('rejected')
              # for editions where reevaluations was NOT revealed
              # we search all accepted with existing reevaluation
              # we search all rejected
              returned_query = returned_query.or(temp_query.where('decidim_projects_projects.state': 'accepted')
                                                           .where('decidim_participatory_processes.reevaluation_publish_date > ?', Date.current)
                                                           .where.not('decidim_projects_evaluations.id': nil))

              returned_query = returned_query.or(temp_query.where('decidim_projects_projects.state': 'rejected')
                                                           .where('decidim_participatory_processes.reevaluation_publish_date > ?', Date.current))
            end
            if options[:state].include?('accepted')
              # for editions where reevaluations was NOT revealed
              # we search all accepted WITHOUT existing reevaluation
              returned_query = returned_query.or(temp_query.where('decidim_projects_projects.state': 'accepted')
                                                           .where('decidim_participatory_processes.reevaluation_publish_date > ?', Date.current)
                                                           .where('decidim_projects_evaluations.id': nil))
            end
            returned_query
          else
            query.where('decidim_projects_projects.state': options[:state]).joins(:component => :process)
                 .where('decidim_participatory_processes.evaluation_publish_date < ?', Date.current)
          end
        else
          query.where('decidim_projects_projects.state': options[:state])
        end
      end

      # Public: method searches for projects with implementation status based on
      # String value of options[:implementation_state]
      #
      # Mapping goes as followes:
      # - *abandoned* -> 0
      # - *finished* -> 5
      # - *in_progress* (or any other) -> 1..4
      #
      # returns query
      def search_implementation_state
        return query if options[:implementation_state].nil?
        return query if options[:implementation_state].blank?

        mapped = options[:implementation_state].map do |op|
          if op == 'abandoned'
            0
          elsif op == 'finished'
            5
          else
            1
          end
        end.uniq
        if mapped.include?(1)
          mapped << 2
          mapped << 3
          mapped << 4
        end

        query.where('decidim_projects_projects.implementation_status': mapped)
      end

      # Public: method searches for projects that are associated with categories (Area) with given IDs
      #
      # returns query
      def search_category
        return query if options[:category].blank? || options[:category] == 'all'

        query.joins(:categories).where('decidim_areas.id': options[:category])
      end

      # Public: method searches for projects that are associated with scope type (via scope) with given IDs
      #
      # returns query
      def search_scope_type
        return query if options[:scope_type].blank? || options[:scope_type] == 'all'

        query.joins(:scope).where('decidim_scopes.scope_type_id': options[:scope_type])
      end

      # Public: method searches for projects that are associated with scopes with given IDs
      #
      # returns query
      def search_scope_id
        return query if options[:scope_id].blank? || options[:scope_id] == 'all'

        query.where('decidim_projects_projects.decidim_scope_id': options[:scope_id])
      end

      # Public: method searches for projects that are associated with recipients with given IDs
      #
      # returns query
      def search_potential_recipient
        return query if options[:potential_recipient].blank? || options[:potential_recipient] == 'all'

        query.joins(:recipients).where('decidim_admin_extended_recipients.id': options[:potential_recipient])
      end

      # Public: method searches for projects with given Array of edition years
      #
      # returns query
      def search_edition_year
        return query if options[:edition_year].blank? || options[:edition_year] == 'all'

        query.where('decidim_projects_projects.edition_year': options[:edition_year])
      end
    end
  end
end
