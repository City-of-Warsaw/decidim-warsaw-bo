# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Projects
    module Admin
      # This Filterable contains whole logic for filtering projects in admin panel
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable
          helper Decidim::Projects::Admin::FilterableHelper

          private

          # filtered collection without pagination, for export
          def full_filtered_collection
            query.result
          end

          # Comment about participatory_texts_enabled.
          def base_query
            accessible_projects_collection
          end

          def accessible_projects_collection
            return collection if current_participatory_space.user_roles(:valuator).where(user: current_user).empty?

            collection.with_valuation_assigned_to(current_user, current_participatory_space)
          end

          def search_field_predicate
            :id_string_or_esog_number_string_or_title_or_body_or_short_description_or_signum_znak_sprawy_cont
          end

          def filters
            all = [
              # :is_emendation_true,
              # :year_eq,
              :state_eq,
              :state_null,
              :verification_status_eq,
              :scope_scope_type_id_eq,
              :scope_id_eq,
              :categories_id_in,
              # :valuator_role_ids_has,
              :is_paper_eq,
              :recipients_id_in
            ]
            # project_states.each { |s| all << "state_#{s}_eq".to_sym }
            # scope_ids_hash(scopes.top_level)
            all
          end

          def filters_with_values
            all = {
              # is_emendation_true: %w(true false),
              # year_eq: years,
              # state_eq: [],
              state_eq: project_states,
              verification_status_eq: project_verification_status,
              scope_scope_type_id_eq: scope_scope_types_ids_hash(scope_types),
              scope_id_eq: scope_ids_hash(scopes),
              categories_id_in: area_ids_hash(areas),
              # area_ids_has: areas_ids_hash(areas),
              # evaluator_id_eq: evaluator_ids_hash(evaluators)
              is_paper_eq: [true, false],
              recipients_id_in: recipient_ids_hash(recipients)
            }
            all
          end

          # Can't user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [:scope_id_eq, :area_id_eq, :valuator_role_ids_has, :scope_scope_type_id_eq, :categories_id_in, :recipients_id_in]
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
          def project_states
            Decidim::Projects::Project::ADMIN_STATES_FOR_SEARCH
          end

          def project_verification_status
            Decidim::Projects::Project::ADMIN_VERIFICATION_STATES_FOR_SEARCH
          end

          def translated_scope_scope_type_id_eq(id)
            translated_attribute(scope_types.find_by(id: id).name)
          end

          def scope_scope_types_ids_hash(scopes)
            scopes.each_with_object({}) do |scope, hash|
              hash[scope.id] = nil
            end
          end

          def scope_types
            Decidim::ScopeType.all
          end

          def scopes
            Decidim::Projects::DistrictScopes.new.query_all_sorted
          end

          # Overwritten
          def translated_scope_id_eq(id)
            translated_attribute(Decidim::Scope.find_by(id: id).name)
          end

          def areas
            Decidim::Area.sorted_by_name
          end

          def area_ids_hash(areas)
            areas.each_with_object({}) do |cat, hash|
              hash[cat.id] = nil
            end
          end

          def recipients
            Decidim::AdminExtended::Recipient.sorted_by_name
          end

          def recipient_ids_hash(recipients)
            recipients.each_with_object({}) do |recipient, hash|
              hash[recipient.id] = nil
            end
          end

          def translated_recipients_id_in(id)
            recipients.find_by(id: id).name
          end

          def translated_categories_id_in(id)
            translated_attribute(areas.find_by(id: id).name)
          end

          def years
            Decidim::ParticipatoryProcess.all.pluck(:edition_year).uniq
          end
        end
      end
    end
  end
end
