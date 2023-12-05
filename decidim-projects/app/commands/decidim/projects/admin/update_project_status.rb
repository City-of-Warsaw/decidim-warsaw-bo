# # frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic when a user updates project status manually.
      class UpdateProjectStatus < Rectify::Command
        include ::Decidim::AttachmentMethods
        include Decidim::Projects::CustomAttachmentsMethods

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # project      - the project to update.
        def initialize(form, project)
          @form = form
          @project = project
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid_budget_value) if @project.budget_value.blank?

          transaction do
            update_project
            send_notification if form.body.present?
          end

          broadcast(:ok, project)
        end

        private

        attr_reader :form, :project, :attachment, :gallery

        # Private: updating project
        #
        # Method does not create version.
        # It adds ActionLog
        #
        # returns project
        def update_project
          PaperTrail.request(enabled: false) do
            @project = Decidim.traceability.perform_action!(
              :change_status,
              project,
              current_user,
              visibility: "admin-only"
            ) do
              project.update(project_params)
              project
            end
          end
        end

        # Private: project params
        #
        # returns Hash
        def project_params
          {
            state: form.state,
            published_at: publication_time,
            chosen_for_voting: chosen_for_voting?,
            esog_number: assign_esog,
            verification_status: verification_status
          }
        end

        # Private: returns publication date
        #
        # Method returns publication date based on it's current state
        # and new status
        #
        # returns Time or nil
        def publication_time
          return if form.state == Decidim::Projects::Project::POSSIBLE_STATES::DRAFT || form.state == 'admin_draft'

          @project.published_at.presence || Time.current
        end

        # Private: returns esog number
        #
        # Method returns esog number based on it's current state
        # and new status
        #
        # returns Integer or nil
        def assign_esog
          if @project.esog_number.blank?
            if form.state == Decidim::Projects::Project::POSSIBLE_STATES::DRAFT || form.state == 'admin_draft'
              return
            else
              Decidim::Projects::Project.generate_esog(@project.participatory_space)
            end
          else
            @project.esog_number
          end
        end

        # Private: returns verification status
        #
        # Method returns verification status based on it's current state
        # and new status
        #
        # returns String or nil
        def verification_status
          return if form.state == Decidim::Projects::Project::POSSIBLE_STATES::DRAFT || form.state == 'admin_draft'

          @project.verification_status.presence || Decidim::Projects::Project::VERIFICATION_STATES::WAITING
        end

        # Private: returns chosen for voting
        #
        # Method returns chosen for voting based on it's current state
        # and new status
        #
        # returns Boolean
        def chosen_for_voting?
          if form.state == Decidim::Projects::Project::POSSIBLE_STATES::ACCEPTED
            true
          elsif form.state == Decidim::Projects::Project::POSSIBLE_STATES::REJECTED
            false
          else
            @project.chosen_for_voting?
          end
        end

        # Private: send message to project authors with body send in form
        #
        # returns nothing
        def send_notification
          Decidim::Projects::NotifyProjectAuthorsJob.perform_later(project_ids: [project.id],
                                                                   body: form.body,
                                                                   subject: "Status Twojego projektu został zmieniony")
        end
      end
    end
  end
end
