# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user returns admin draft project to be corrected.
      class ReturnAdminDraft < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'return_admin_draft'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[0]
          return broadcast(:invalid) unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING
          return broadcast(:invalid) unless editor

          transaction do
            send_project_back_to_editor
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user

        def send_project_back_to_editor
          @project = Decidim.traceability.perform_action!(
            :return,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            project.save(validate: false)
            project
          end
        end

        def project_attributes
          {
            evaluator: editor, # addigning first association - Editor
            verification_status: nil # cleared since no longer in verification flow
          }
        end

        def editor
          project.users.first
        end

        # Public: returns Object - Department based on the project's scope
        # or current_user department
        def department
          project.scope&.department || current_user.department
        end

        def send_notification
          Decidim::Projects::EvaluationMailer.notify(project, action, current_user, editor).deliver_later
        end
      end
    end
  end
end
