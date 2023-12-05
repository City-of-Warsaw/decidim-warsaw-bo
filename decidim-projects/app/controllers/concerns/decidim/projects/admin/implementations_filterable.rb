# frozen_string_literal: true

require 'active_support/concern'

module Decidim
  module Projects
    module Admin
      # This Filterable contains whole logic for filtering implementations in admin panel
      module ImplementationsFilterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          # Overwritten to add distinct: true
          def filtered_collection
            paginate(query.result(distinct: true))
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
            :id_string_or_esog_number_string_or_title_or_body_or_short_description_or_producer_list_or_implementations_body_cont
          end

          def filters
            [
              :scope_id_eq,
              :implementation_status_eq,
              :implementation_photos_exists_true
            ]
          end

          def filters_with_values
            all = {
              scope_id_eq: scope_ids_hash(scopes),
              implementation_status_eq: [0, 1, 2, 3, 4, 5],
              implementation_photos_exists_true: [1, 0]
            }
            all
          end

          # Can't user `super` here, because it does not belong to a superclass
          # but to a concern.
          def dynamically_translated_filters
            [
              :scope_id_eq,
              :area_id_eq,
              :valuator_role_ids_has,
              :scope_type_id_eq,
              :area_ids_has,
              :implementation_status_eq
            ]
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
            Decidim::Projects::Project::STATES_FOR_SEARCH
          end

          def translated_scope_type_id_eq(id)
            translated_attribute(scope_types.find_by(id: id).name)
          end

          def translated_implementation_status_eq(id)
            I18n.t(
              id,
              scope: 'decidim.admin.filters.projects.implementation_status_eq.values',
              default: 'decidim.admin.filters.projects.implementation_status_eq.values.default'
            )
          end

          def scope_types_ids_hash(scopes)
            scopes.each_with_object({}) do |scope, hash|
              hash[scope.id] = nil
            end
          end

          def scope_types
            Decidim::ScopeType.all
          end

          def scopes
            og = Decidim::Projects::DistrictScopes.new.citywide_scope
            mapped = Decidim::Projects::DistrictScopes.new.query.sort { |a, b| a.name['pl'] <=> b.name['pl'] }
            [og] + mapped
          end

          # Overwritten
          def scope_ids_hash(scopes)
            scopes.each_with_object({}) do |scope, hash|
              hash[scope.id] = nil
            end
          end

          # Overwritten
          def translated_scope_id_eq(id)
            translated_attribute(Decidim::Scope.find_by(id: id).name)
          end

          def areas
            Decidim::Area.sorted_by_name
          end

          def areas_ids_hash(areas)
            areas.each_with_object({}) do |cat, hash|
              hash[cat.id] = nil
            end
          end

          def translated_area_ids_has(id)
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
