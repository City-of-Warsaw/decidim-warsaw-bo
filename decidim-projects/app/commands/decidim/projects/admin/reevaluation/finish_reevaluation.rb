# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Reevaluation
      # A command with all the business logic when a user finishes reevaluation.
      class FinishReevaluation < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(appeal, current_user)
          @appeal = appeal
          @project = appeal.project
          @current_user = current_user
          @action = 'reevaluation_finished'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless appeal
          return broadcast(:invalid) unless user_can_accept?
          # return broadcast(:invalid) unless [true, false].include? project.reevaluation.details['result']
          return broadcast(:invalid) unless project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING,
                                                                             Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION,
                                                                             Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION_FINISHED,
                                                                             Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_ADMIN_VERIFICATION,
                                                                             Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_COORDINATOR_FINISHED])
          return broadcast(:invalid_budget) if project.with_invalid_budget?
          return broadcast(:invalid_reevaluation_result) unless project.reevaluation.can_be_approved?

          transaction do
            @project.reevaluation.save_pdf_to_file
            submit_for_reevaluation
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :appeal

        def submit_for_reevaluation
          @project = Decidim.traceability.perform_action!(
            :reevaluation_finished,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            project
          end
        end

        def project_attributes
          {
            verification_status: Decidim::Projects::Project::REEVALUATION_STATES::REEVALUATION_FINISHED,
            reevaluation_result: positive_reevaluation_result?,
            state: project_final_status,
            evaluator: nil
          }
        end

        # Public: returns Object - Current department of the project or
        # Department based on the project's scope
        # or current_user department
        def department
          project.current_department || project.scope&.department || current_user.department
        end

        def user_can_accept?
          current_user.ad_admin?
        end

        # true if reevaluation was success
        # return Boolean
        def positive_reevaluation_result?
          @project.reevaluation.positive_result?
        end

        # return projects state after reevaluation: changed or not
        def project_final_status
          if positive_reevaluation_result?
            Decidim::Projects::Project::POSSIBLE_STATES::ACCEPTED
          else
            Decidim::Projects::Project::POSSIBLE_STATES::REJECTED
          end
        end

        def send_notification
          return if department&.coordinators.none?
          
          # mail to coordinators about final decision
          department.coordinators.each do |admin|
            Decidim::Projects::ReevaluationJob.perform_later(project, action, current_user, admin)
          end
        end
      end
    end
  end
end
