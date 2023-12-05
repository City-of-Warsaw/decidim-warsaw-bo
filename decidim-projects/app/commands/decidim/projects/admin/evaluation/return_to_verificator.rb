# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user returns project to evaluator to be corrected.
      class ReturnToVerificator < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, current_user)
          @form = form
          @project = form.project
          @evaluator = @project.evaluator
          @current_user = current_user
          @note = form.body
          @current_state = @project.verification_status
          @action = 'return_to_verificator'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::POSSIBLE_STATES::PUBLISHED
          return broadcast(:invalid) unless ['formal_finished', 'meritorical_finished'].include?(@current_state)
          return broadcast(:invalid) unless evaluator

          transaction do
            send_project_back_to_evaluator
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :form, :project, :action, :current_user, :evaluator, :note

        def send_project_back_to_evaluator
          @project = Decidim.traceability.perform_action!(
            :return_to_verificator,
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
            # evaluator: evaluator, # is still set
            verification_status: verification_status,
            evaluation_note: note.presence || project.evaluation_note
          }
        end

        # Public: returns Object - Department based on the project's scope
        # or current_user department
        def department
          project.scope&.department || current_user.department
        end

        def verification_status
          case @current_state
          when 'formal_finished'
            Decidim::Projects::Project::VERIFICATION_STATES::FORMAL
          when 'meritorical_finished'
            Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL
          end
        end

        def send_notification
          return if evaluator.email.blank?

          Decidim::Projects::EvaluationMailer.notify(project, action, current_user, evaluator).deliver_later
        end
      end
    end
  end
end
