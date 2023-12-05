# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user changes evaluator in project.
      class ChangeVerificator < Rectify::Command

        # Public: Initializes the command.
        # project - Decidim::Projects::Project
        # current_user - user which assign project to verificator
        # evaluator - new verificator, or nil when verificator is unassigned
        def initialize(project, current_user, evaluator)
          @project = project
          @evaluator = evaluator # new evaluator
          @current_user = current_user
          @action = @evaluator ? 'change_verificator' : 'unassign_verificator'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          transaction do
            assign_project_to_verification
            send_notification if evaluator
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :evaluator

        def assign_project_to_verification
          @project = Decidim.traceability.perform_action!(
            @action,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(evaluator: evaluator)
            project.users << evaluator if evaluator && !project.users.include?(evaluator)
            project.save(validate: false)
            project
          end
        end

        def send_notification
          return if evaluator.blank? || evaluator.email.blank?

          Decidim::Projects::EvaluationMailer.notify_with_template(project, action, current_user, evaluator).deliver_later
        end
      end
    end
  end
end
