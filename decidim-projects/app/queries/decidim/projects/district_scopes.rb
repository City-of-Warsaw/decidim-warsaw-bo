# frozen_string_literal: true

# Decidim::Projects::DistrictScopes.new.query
module Decidim
  module Projects
    # A class used to find the scopes as districts only
    class DistrictScopes < Rectify::Query
      GLOBAL_SCOPE_ID = Decidim::Scope.find_by(code: 'om').id

      def query
        Decidim::Scope.where.not(id: GLOBAL_SCOPE_ID).by_position
      end

      def query_all_sorted
        Decidim::Scope.by_position
      end

      def citywide_scope
        Decidim::Scope.where(id: GLOBAL_SCOPE_ID).first
      end
    end
  end
end
