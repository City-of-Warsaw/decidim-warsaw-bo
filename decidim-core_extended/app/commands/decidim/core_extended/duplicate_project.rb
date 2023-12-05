# frozen_string_literal: true

module Decidim
  module CoreExtended
    # A command with all the business logic when a user duplicates a project.
    class DuplicateProject < Rectify::Command
      # Public: Initializes the command.
      #
      # project
      # current_user - The current user
      def initialize(project, current_user, component)
        @project = project
        @current_user = current_user
        @component = component
        @participatory_space = component.participatory_space
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed
      # - :invalid if there was no project
      # - :invalid if attachments are invalid
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless project
        return broadcast(:invalid) unless participatory_space
        return broadcast(:invalid) unless component

        transaction do
          create_project
        end

        broadcast(:ok)
      end

      private

      attr_reader :project, :current_user, :participatory_space, :component

      def create_project
        PaperTrail.request(enabled: false) do
          @new_project = Decidim.traceability.perform_action!(
            :user_create,
            Decidim::Projects::Project,
            current_user,
            visibility: "all"
          ) do
            project = Decidim::Projects::Project.new(project_attributes)
            Decidim::Projects::ProjectAuthorsManager.new(project).add_author(current_user)

            project.save!
            project
          end
        end
        # associations
        @new_project.categories = project.categories
        @new_project.recipients = project.recipients
      end

      def project_attributes
        {
          state: Decidim::Projects::Project::POSSIBLE_STATES::DRAFT,
          component: component,
          edition_year: participatory_space.edition_year,
          title: @project.title,
          body: @project.body,
          short_description: @project.short_description,
          universal_design: @project.universal_design.is_a?(Array) ? @project.universal_design[1] : @project.universal_design,
          universal_design_argumentation: @project.universal_design_argumentation,
          justification_info: @project.justification_info,
          localization_info: @project.localization_info,
          localization_additional_info: @project.localization_additional_info,
          budget_value: @project.budget_value,
          scope: @project.scope,
          locations: @project.locations,
          custom_categories: @project.custom_categories,
          custom_recipients: @project.custom_recipients,
          additional_data: @project.additional_data
        }
      end
    end
  end
end
