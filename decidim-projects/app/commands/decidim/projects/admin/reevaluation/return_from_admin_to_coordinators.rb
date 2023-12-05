# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      module Reevaluation
        # A command with all the business logic when a admin wants to return appeal to reverification.
        class ReturnFromAdminToCoordinators < Rectify::Command
          # Public: Initializes the command.
          #
          # form - A form object with the params.
          def initialize(appeal, current_user)
            @appeal = appeal
            @project = appeal.project
            @current_user = current_user
            @action = 'return_from_admin_to_coordinators'
          end

          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid, together with the proposal.
          # - :invalid if the form wasn't valid and we couldn't proceed.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless appeal
            return broadcast(:invalid) unless project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_ADMIN_VERIFICATION,
                                                                               Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_COORDINATOR_FINISHED])

            transaction do
              return_from_admin_to_coordinators
              send_notification
            end
            broadcast(:ok, project)
          end

          # private

          attr_reader :project, :action, :current_user, :appeal

          def return_from_admin_to_coordinators
            @project = Decidim.traceability.perform_action!(
              :return_from_admin_to_coordinators,
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
              verification_status: 'appeal_verification_finished'
            }
          end

          # Public: returns Object - Current department of the project or
          # Department based on the project's scope
          # or current_user department
          def department
            project.current_department || project.scope&.department || current_user.department
          end

          def send_notification
            return if department.coordinators.none?

            department.coordinators.each do |coordinator|
              Decidim::Projects::ReevaluationMailer.return_reevaluation_from_admin_to_coordinator(project, current_user, coordinator).deliver_later
            end
          end
        end
      end
    end
  end
end
