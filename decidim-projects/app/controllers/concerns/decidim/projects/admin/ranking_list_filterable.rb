# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Projects
    module Admin
      # This Filterable contains whole logic for filtering projects on ranking list in admin panel
      module RankingListFilterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          # A base query for filter projects on ranking list
          def base_query
            collection
          end

          def search_field_predicate
            :project_title_or_project_esog_number_string_cont
          end

          def filters
            [
              :scope_id_eq
            ]
          end

          def filters_with_values
            {
              scope_id_eq: scope_ids_hash(scopes)
            }
          end

        end
      end
    end
  end
end
