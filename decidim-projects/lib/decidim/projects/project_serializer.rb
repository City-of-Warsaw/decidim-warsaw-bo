# frozen_string_literal: true

module Decidim
  module Projects
    # This class serializes a Project so can be exported to CSV, JSON or other
    # formats.
    class ProjectSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a proposal.
      def initialize(project)
        @project = project
      end

      # Public: Exports a hash with the serialized data for this proposal.
      def serialize
        {
          id: project.id,
          voting_number: project.voting_number,
          esog_number: project.esog_number,
          is_paper: project.is_paper ? 'papierowo' : 'elektronicznie',
          published_at: project.published_at,
          title: project.title,
          # user_id:
          short_description: project.short_description,
          scope_group: project.scope.scope_type.name, # poziom
          scope: project.scope.name, # dzielnica
          localization_info: project.localization_info,
          localization_additional_info: project.localization_additional_info,
          budget_value: project.budget_value,
          body: project.body,
          universal_design: project.universal_design.nil? ? 'Brak informacji' : project.universal_design ? 'Tak' : 'Nie',
          universal_design_argumentation: project.universal_design_argumentation,
          justification_info: project.justification_info

          # category: {
          #   id: project.category.try(:id),
          #   name: project.category.try(:name) || empty_translatable
          # },
          # scope: {
          #   id: project.scope.try(:id),
          #   name: project.scope.try(:name) || empty_translatable
          # },
          # participatory_space: {
          #   id: project.participatory_space.id,
          #   url: Decidim::ResourceLocatorPresenter.new(project.participatory_space).url
          # },
          # component: { id: component.id },
          # state: project.state.to_s,
          # reference: project.reference,
          # answer: ensure_translatable(project.answer),
          # supports: project.proposal_votes_count,
          #
          # comments: project.comments_count,
          # attachments: project.attachments.count,
          # followers: project.followers.count,

          # url: url,
        }
      end

      private

      attr_reader :project

      def component
        project.component
      end

      def related_proposals
        project.linked_resources(:proposals, "copied_from_component").map do |project|
          Decidim::ResourceLocatorPresenter.new(project).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(project).url
      end


      def original_project_url
        return unless project.emendation? && project.amendable.present?

        Decidim::ResourceLocatorPresenter.new(project.amendable).url
      end
    end
  end
end
