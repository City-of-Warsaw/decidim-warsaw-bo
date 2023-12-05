# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user forwards project to different department.
      class ForwardToDepartment < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user, department)
          @project = project
          @current_user = current_user
          @department = department
          @action = 'forward_to_department'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if there is no department
        # - :no_ad_name if department has no ad_name set
        # - :no_coordinators if there are no coordinators in department
        # - :invalid_state if project is a draft or was withdrawn by author
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless department
          return broadcast(:no_ad_name) if department.ad_name.blank?
          return broadcast(:no_coordinators) if department.coordinators.none?
          return broadcast(:invalid_state) if project.state == Decidim::Projects::Project::POSSIBLE_STATES::DRAFT ||
                                                    project.state == Decidim::Projects::Project::POSSIBLE_STATES::WITHDRAWN

          forward_project_to_department
          send_notification

          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :department

        def forward_project_to_department
          @project = Decidim.traceability.perform_action!(
            :forward_to_department,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.current_department_id = department.id
            project.save(validate: false)
            project.department_assignments.create(department: department)
            project
          end
        end

        def send_notification
          mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'project_assigned_to_department_email_template')
          return unless mail_template&.filled_in?

          department.coordinators.each do |user|
            Decidim::Projects::TemplatedMailerJob.perform_later(project, user, mail_template)
          end
        end
      end
    end
  end
end
