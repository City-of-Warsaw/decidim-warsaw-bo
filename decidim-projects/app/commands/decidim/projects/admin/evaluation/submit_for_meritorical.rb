# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user assigns project to evaluator for meritorical evaluation.
      class SubmitForMeritorical < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user, evaluator)
          @project = project
          @evaluator = evaluator
          @current_user = current_user
          @action = 'submit_for_meritorical'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless evaluator
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[1] # published
          # return broadcast(:invalid) unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED
          return broadcast(:invalid) unless project.formal_result # formal must be positive

          transaction do
            submit_project_for_meritorical_verification
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :evaluator

        def submit_project_for_meritorical_verification
          @project = Decidim.traceability.perform_action!(
            :meritorical,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            project.users << evaluator
            project.save(validate: false)
            project
          end
        end

        def project_attributes
          {
            evaluator: evaluator,
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL
          }
        end

        def send_notification
          return if evaluator.email.blank?

          Decidim::Projects::EvaluationMailer.notify_with_template(project, action, current_user, evaluator).deliver_later
        end
      end
    end
  end
end
