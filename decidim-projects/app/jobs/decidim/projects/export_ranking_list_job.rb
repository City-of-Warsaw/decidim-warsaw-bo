# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to the voting.
    class ExportRankingListJob < ApplicationJob

      queue_as :events

      def perform(user, component, name, format, scope)
        export_manifest = component.manifest.export_manifests.find do |manifest|
          manifest.name == name.to_sym
        end

        collection = export_manifest.collection.call(component, user, scope)
        serializer = export_manifest.serializer

        budget_value = component.participatory_space.scope_budgets.find_by(decidim_scope_id: scope.id)&.budget_value
        projects_total_budget_value =  collection.on_the_list.joins(:project).sum('decidim_projects_projects.budget_value')

        valid_cards_count = if scope.citywide?
                              Decidim::Projects::UserVoteCards.for(user, component).valid.with_global_votes.count
                            else
                              Decidim::Projects::UserVoteCards.for(user, component).valid.with_district_votes.where(scope: scope).count
                            end

        export_data = if format == 'xlsx'
                        Decidim::Exporters::RankingListExcelExporter.new(collection, serializer, scope, budget_value, projects_total_budget_value, valid_cards_count).export
                      else
                        Decidim::Exporters::RankingListPDFExporter.new(collection, serializer, scope, budget_value, projects_total_budget_value, valid_cards_count).export
                      end

        ExportMailer.export(user, name, export_data).deliver_now
      end

      private

      def csv_data; end
    end
  end
end
