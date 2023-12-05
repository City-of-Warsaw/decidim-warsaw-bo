# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user accepts meritorical evaluation.
      class AcceptMeritorical < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'meritorical_accepted'
          @department = project.current_department
          @evaluation = @project.meritorical_evaluation
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
          return broadcast(:invalid) unless can_accept?
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::POSSIBLE_STATES::PUBLISHED
          return broadcast(:invalid) if project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_ACCEPTED
          return broadcast(:invalid) if project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FINISHED
          return broadcast(:invalid_budget) if project.with_invalid_budget?

          transaction do
            accept_project_meritorical_verification
            @evaluation.save_pdf_to_file
            # send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :evaluation, :department

        def accept_project_meritorical_verification
          @project = Decidim.traceability.perform_action!(
            :meritorical_accepted,
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
          @project.meritorical_evaluation
        end

        def can_accept?
          current_user.ad_admin? || (current_user.ad_coordinator? && current_user.department == project.current_department)
        end

        def project_attributes
          {
            evaluator: nil, # clearing
            # publishing
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_ACCEPTED,
            # state: Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[1],
            meritorical_result: result_from_evaluation
          }
        end

        def result_from_evaluation
          case evaluation.result
          when 2
            false
          when 1
            true
          end
        end
      end
    end
  end
end
