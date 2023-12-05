# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user finishes meritorical evaluation.
      class FinishMeritorical < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'finish_meritorical'
          @department = project.current_department
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :invalid_budget if project's budget is blank or invalid
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless evaluation
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[1]
          return broadcast(:invalid) unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL # meritorical
          return broadcast(:invalid_budget) if project.with_invalid_budget?

          transaction do
            submit_project_for_meritorical_verification
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :evaluation, :department

        def submit_project_for_meritorical_verification
          @project = Decidim.traceability.perform_action!(
            :meritorical_finish,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            project.save(validate: false)
            project
          end
        end

        def evaluation
          @project.meritorical_evaluation
        end

        def project_attributes
          {
            # evaluator: nil, # not clearing, evaluator can still edit his evaluation
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_FINISHED, # meritorical_finished
            evaluation_note: nil # clearing note if necessary
          }
        end

        def send_notification
          return unless department

          if department.coordinators.any?
            Decidim::Projects::EvaluationJob.perform_later(project, action, current_user, department)
          end
        end
      end
    end
  end
end
