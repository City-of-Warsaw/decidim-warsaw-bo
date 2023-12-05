# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Projects
    module Admin
      # This Filterable contains whole logic for filtering appeals in admin panel
      module AppealsFilterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          def query
            @query ||= custom_search(ransack_params)
          end

          private

          def filtered_collection
            query
          end

          # Comment about participatory_texts_enabled.
          def base_query
            accessible_appeals_collection
          end

          def custom_search(ransack_params)
            bq = base_query
            if ransack_params[:is_paper]
              val = ransack_params[:is_paper] == 'true' ? true : false
              bq = bq.where("decidim_projects_appeals.is_paper": val)
            end
            if ransack_params[:state_eq]
              bq = bq.joins(:project).where("decidim_projects_projects.verification_status": ransack_params[:state_eq])
            end
            if ransack_params[:scope_id_eq]
              bq = bq.joins(:project).where("decidim_projects_projects.decidim_scope_id": ransack_params[:scope_id_eq])
            end
            if ransack_params[:scope_scope_type_id_eq]
              bq = bq.joins(project: [:scope]).where("decidim_scopes.scope_type_id": ransack_params[:scope_scope_type_id_eq])
            end
            bq.ransack(body_or_project_title_or_esog_number_string_cont: ransack_params[search_field_predicate])
          end

          def accessible_appeals_collection
            # return @appeals if current_participatory_space.user_roles(:valuator).where(user: current_user).empty?

            collection
          end

          def search_field_predicate
            :body_or_project_title_or_esog_number_string_cont
          end

          def filters
            [
              # :is_emendation_true,
              :state_eq,
              :is_paper,
              :scope_id_eq,
              :category_id_eq,
              :scope_scope_type_id_eq
            ]
          end

          def filters_with_values
            {
              # is_emendation_true: %w(true false),
              state_eq: appeal_states,
              is_paper: [true, false],
              scope_id_eq: scope_ids_hash(scopes),
              scope_scope_type_id_eq: scope_scope_types_ids_hash(scope_types)
            }
          end

          # Can't user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:state_eq, :category_id_eq,:scope_scope_type_id_eq, :scope_id_eq, :valuator_role_ids_has]
          end

          def scope_scope_types_ids_hash(scopes)
            scopes.each_with_object({}) do |scope, hash|
              hash[scope.id] = nil
            end
          end

          def scope_types
            Decidim::ScopeType.all
          end

          def translated_state_eq(s)
            I18n.t(s, scope: 'decidim.admin.filters.appeals.state_eq.values')
          end

          def translated_scope_scope_type_id_eq(id)
            translated_attribute(scope_types.find_by(id: id).name)
          end

          def valuator_role_ids
            current_participatory_space.user_roles(:valuator).pluck(:id)
          end

          def translated_valuator_role_ids_has(valuator_role_id)
            user_role = current_participatory_space.user_roles(:valuator).find_by(id: valuator_role_id)
            user_role&.user&.name
          end

          # An Array<Symbol> of possible values for `state_eq` filter.
          # Excludes the states that cannot be filtered with the ransack predicate.
          # A link to filter by "Not answered" will be added in:
          # Decidim::Proposals::Admin::FilterableHelper#extra_dropdown_submenu_options_items
          def appeal_states
            Decidim::Projects::Project::REEVALUATION_STATES_INLINE
          end
        end
      end
    end
  end
end
