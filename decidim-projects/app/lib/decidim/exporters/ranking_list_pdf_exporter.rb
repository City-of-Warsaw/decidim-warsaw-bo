# frozen_string_literal: true

module Decidim
  module Exporters
    class RankingListPDFExporter < PDF

      def initialize(collection, serializer, scope, budget_value, projects_total_budget_value, valid_cards_count)
        @collection = collection
        @serializer = serializer
        @scope = scope
        @budget_value = budget_value
        @projects_total_budget_value = projects_total_budget_value
        @valid_cards_count = valid_cards_count
      end

      def template
        'decidim/projects/admin/ranking_lists/winners_list.html.erb'
      end

      # no need layout for this pdf
      def layout
        nil
      end

      # variables for template
      def locals
        {
          collection: collection,
          scope: scope,
          budget_value: @budget_value,
          projects_total_budget_value: @projects_total_budget_value,
          valid_cards_count: @valid_cards_count
        }
      end

      protected

      def controller
        Decidim::Projects::Admin::RankingListsController.new
      end

      private

      attr_reader :scope

    end
  end
end
