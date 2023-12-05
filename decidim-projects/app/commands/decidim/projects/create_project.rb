# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user creates a new project.
    class CreateProject < Rectify::Command
      include ::Decidim::AttachmentMethods
      include Decidim::Projects::CustomAttachmentsMethods

      # Public: Initializes the command.
      #
      # form          - A form object with the params.
      # current_user  - The current user.
      # coauthorships - The coauthorships of the project - optional
      def initialize(form, current_user, coauthorships = nil)
        @form = form
        @current_user = current_user
        @coauthorships = coauthorships
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the project.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # - :invalid if attachments are invalid
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        build_endorsements_for(nil)
        build_files_for(nil)
        build_consents_for(nil)
        return broadcast(:invalid) if endorsements_invalid? || files_invalid? || consents_invalid?

        transaction do
          create_project
        end

        broadcast(:ok, project)
      end

      private

      attr_reader :form, :project, :attachment

      # private method
      #
      # Creating project and preventing PaperTrail from creating
      # an additional version
      # in the project multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the project version control
      #
      # returns Object - Project
      def create_project
        PaperTrail.request(enabled: false) do
          @project = Decidim.traceability.perform_action!(
            :user_create,
            Decidim::Projects::Project,
            @current_user,
            visibility: "all"
          ) do
            project = Decidim::Projects::Project.new(project_attributes)
            ProjectAuthorsManager.new(project).add_author(@current_user)

            build_endorsements_for(project)
            build_consents_for(project)
            build_files_for(project)

            project.save!
            project
          end
        end
        # associations
        project.categories = form.assigned_categories
        project.recipients = form.recipients
        @attached_to = @project
      end

      # private method
      #
      # returns Hash - mapped attributes for creating a project
      def project_attributes
        {
          # default
          state: Decidim::Projects::Project::POSSIBLE_STATES::DRAFT,
          # is_paper: false, #default
          component: form.component,
          edition_year: form.component.participatory_space&.edition_year,
          # custom
          title: form.title,
          body: form.body,
          short_description: form.short_description,
          universal_design: form.universal_design.is_a?(Array) ? form.universal_design[1] : form.universal_design,
          universal_design_argumentation: form.universal_design_argumentation,
          justification_info: form.justification_info,
          localization_info: form.localization_info,
          localization_additional_info: form.localization_additional_info,
          budget_value: form.budget_value,
          scope: form.scope,
          locations: form.locations_data,
          custom_categories: form.custom_categories,
          custom_recipients: form.custom_recipients,
          additional_data: form.additional_data
        }
      end

      # private method
      #
      # returns Object - Organization from current_user
      def organization
        @organization ||= @current_user.organization
      end
    end
  end
end
