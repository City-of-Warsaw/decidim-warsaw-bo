# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Reevaluation
      # A command with all the business logic when a user assigns project to evaluator for reevaluation.
      class SubmitForVerification < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(appeal, current_user, evaluator)
          @appeal = appeal
          @project = appeal.project
          @evaluator = evaluator
          @current_user = current_user
          @action = 'submit_appeal_for_verification'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless appeal

          transaction do
            submit_for_reevaluation
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :evaluator, :appeal

        def submit_for_reevaluation
          @project = Decidim.traceability.perform_action!(
            :submit_appeal_for_verification,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            project.users << evaluator
            project
          end
        end

        def project_attributes
          {
            evaluator: evaluator, # setting evaluator
            verification_status: Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION
          }
        end

        # Public: returns Object - Current department of the project or
        # Department based on the project's scope
        # or current_user department
        def department
          project.current_department || project.scope&.department || current_user.department
        end

        def send_notification
          return if evaluator.email.blank?

          Decidim::Projects::EvaluationMailer.notify_with_template(project, action, current_user, evaluator).deliver_later
        end
      end
    end
  end
end
