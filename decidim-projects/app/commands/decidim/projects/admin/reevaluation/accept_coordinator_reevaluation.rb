# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      module Reevaluation
        # A command with all the business logic when coordinator accept reevaluation.
        class AcceptCoordinatorReevaluation < Rectify::Command
          # Public: Initializes the command.
          #
          # form - A form object with the params.
          def initialize(appeal, current_user)
            @appeal = appeal
            @project = appeal.project
            @current_user = current_user
            @action = 'accept_coordinator_reevaluations'
          end

          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid, together with the proposal.
          # - :invalid if the form wasn't valid and we couldn't proceed.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless appeal
            return broadcast(:invalid) unless project.verification_status == 'appeal_verification_finished'

            transaction do
              accept_coordinator_reevaluations
              send_notification
            end
            broadcast(:ok, project)
          end

          # private

          attr_reader :project, :action, :current_user, :appeal

          def accept_coordinator_reevaluations
            @project = Decidim.traceability.perform_action!(
              :accept_coordinator_reevaluations,
              project,
              current_user,
              visibility: 'admin-only'
            ) do
              project.update(project_attributes)
              project
            end
          end

          def project_attributes
            {
              verification_status: 'appeal_coordinator_finished'
            }
          end

          # Public: returns Object - Current department of the project or
          # Department based on the project's scope
          # or current_user department
          def department
            project.current_department || project.scope&.department || current_user.department
          end

          def send_notification
            Decidim::User.admins.each do |admin|
              Decidim::Projects::ReevaluationMailer.accept_coordinator_reevaluation(project, admin).deliver_later
            end
          end
        end
      end
    end
  end
end
