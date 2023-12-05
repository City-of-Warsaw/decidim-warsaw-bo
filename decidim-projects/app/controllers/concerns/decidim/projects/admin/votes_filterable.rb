# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Projects
    module Admin
      # This Filterable contains whole logic for filtering votes in admin panel
      module VotesFilterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          # A base query for filter votes
          def base_query
            collection
          end

          def search_field_predicate
            :first_name_or_last_name_or_pesel_number_or_ip_number_or_email_or_card_number_or_author_first_name_or_author_last_name_cont
          end

          def filters
            [
              :is_paper_eq,
              :status_eq,
              :scope_id_eq
            ]
          end

          def filters_with_values
            {
              is_paper_eq: [true, false],
              status_eq: vote_statuses,
              # scope_type_id_eq: scope_types_ids_hash(scope_types)
              scope_id_eq: scope_ids_hash(scopes)
            }
          end

          # An Array<Symbol> of possible values for `status_eq` filter.
          # Excludes the statuses that cannot be filtered with the ransack predicate.
          # A link to filter by "Not answered" will be added in:
          # Decidim::Projects::Admin::FilterableHelper#extra_dropdown_submenu_options_items
          def vote_statuses
            Decidim::Projects::VoteCard::ADMIN_STATES_FOR_SEARCH
          end

        end
      end
    end
  end
end
