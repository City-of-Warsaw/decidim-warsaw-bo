# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user finishes formal evaluation.
      class FinishFormal < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'finish_formal'
          @department = project.current_department
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless evaluation
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[1]
          return broadcast(:invalid) unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL

          transaction do
            submit_project_for_formal_verification
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :evaluation, :department

        def submit_project_for_formal_verification
          @project = Decidim.traceability.perform_action!(
            :formal_finish,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.assign_attributes(project_attributes)
            project.save(validate: false)
            project
          end
        end

        def evaluation
          @project.formal_evaluation
        end

        def project_attributes
          {
            # evaluator: nil, # not clearing - evaluator may still edit
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_FINISHED,
            evaluation_note: nil # clearing note if necessary
          }
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
