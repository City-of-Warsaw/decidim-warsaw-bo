# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user finishes admin draft.
      class FinishAdminDraft < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'finish_admin_draft'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[0]
          return broadcast(:invalid) unless project.verification_status.nil?

          transaction do
            send_project_to_coordinator
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user

        def send_project_to_coordinator
          @project = Decidim.traceability.perform_action!(
            :send,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            project.departments << department # assign department
            project.save(validate: false)
            project
          end
        end

        def project_attributes
          {
            evaluator: nil,
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::WAITING,
            current_department: department
          }
        end

        # Public: returns Object - Department based on the project's scope
        # or current_user department
        def department
          project.scope&.department.presence || current_user.department
        end

        def send_notification
          if department.coordinators.any?
            Decidim::Projects::EvaluationJob.perform_later(project, action, current_user, department)
          end
        end
      end
    end
  end
end
