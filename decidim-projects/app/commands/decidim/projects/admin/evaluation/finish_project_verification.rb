# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user finishes first evaluation.
      class FinishProjectVerification < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'finish_project_verification'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :invalid_budget if project's budget is blank or invalid
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[1]
          return broadcast(:invalid) unless ['formal_accepted', 'meritorical_accepted'].include?(project.verification_status)
          return broadcast(:invalid_budget) if project.with_invalid_budget?

          transaction do
            finish_verification
          end
          broadcast(:ok, project)
        end

        attr_reader :project, :action, :current_user

        def finish_verification
          @project = Decidim.traceability.perform_action!(
            :verification_finish,
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
            evaluator: nil, # clearing
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::FINISHED, # finished
            state: project_final_status
          }
        end

        def project_final_status
          if project.formal_result && project.meritorical_result
            Decidim::Projects::Project::POSSIBLE_STATES::ACCEPTED
          else
            Decidim::Projects::Project::POSSIBLE_STATES::REJECTED
          end
        end
      end
    end
  end
end
