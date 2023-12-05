# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      module Reevaluation
        # A command with all the business logic when a user submit reevaluation to admins for final acceptance.
        class SubmitToOrganizationAdmin < Rectify::Command
          # Public: Initializes the command.
          #
          # form - A form object with the params.
          def initialize(appeal, current_user)
            @appeal = appeal
            @project = appeal.project
            @current_user = current_user
            @action = 'submit_verified_appeal'
          end

          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid, together with the proposal.
          # - :invalid if the form wasn't valid and we couldn't proceed.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless appeal
            return broadcast(:invalid) unless can_accept?
            return broadcast(:invalid) unless project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING ||
                                              project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION ||
                                              project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION_FINISHED ||
                                              project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_COORDINATOR_FINISHED

            transaction do
              submit_for_reevaluation
              send_notification
            end
            broadcast(:ok, project)
          end

          # private

          attr_reader :project, :action, :current_user, :appeal

          def submit_for_reevaluation
            @project = Decidim.traceability.perform_action!(
              :submit_verified_appeal,
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
              # evaluator: nil, # clearing - only admins can edit now
              verification_status: Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_ADMIN_VERIFICATION
            }
          end

          # Public: returns Object - Current department of the project or
          # Department based on the project's scope
          # or current_user department
          def department
            project.current_department || project.scope&.department || current_user.department
          end

          def can_accept?
            current_user.ad_admin? || (current_user.ad_coordinator? && current_user.department == project.current_department)
          end

          def send_notification
            Decidim::User.admins.each do |admin|
              Decidim::Projects::ReevaluationMailer.final_acceptance_admin_info(project, admin).deliver_later
            end
          end
        end
      end
    end
  end
end
