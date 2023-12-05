# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Reevaluation
      # A command with all the business logic when a user accepts appeal.
      class AcceptPaperAppeal < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(appeal, current_user)
          @appeal = appeal
          @project = appeal.project
          @current_user = current_user
          @action = 'accept_paper_appeal'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless appeal
          # return broadcast(:invalid) if project.is_in_reevaluation?

          transaction do
            send_appeal_to_coordinator
            # send_notification
          end
          broadcast(:ok, @project)
        end

        # private

        attr_reader :project, :action, :current_user, :appeal

        def send_appeal_to_coordinator
          @project = Decidim.traceability.perform_action!(
            :accept_paper_appeal,
            @project,
            current_user,
            visibility: "admin-only"
          ) do
            @project.update(project_attributes)
            @project
          end
        end

        def project_attributes
          {
            evaluator: nil, # clearing - editor can NOT edit anymore
            verification_status: Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING
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

          department.coordinators.each do |admin|
            Decidim::Projects::ReevaluationJob.perform_later(project, action, current_user, admin)
          end
        end
      end
    end
  end
end
