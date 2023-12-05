# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module AdminExtended
    module Admin
      # This Filterable contains whole logic for filtering comments in admin panel
      module CommentsFilterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          # A base query for filter projects on voting list
          def base_query
            collection
          end

          def search_field_predicate
            :body_cont
          end

          def filters
            []
          end

          def filters_with_values
            {}
          end

        end
      end
    end
  end
end
