# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user returns project to previous department.
      class ReturnToDepartment < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, current_user)
          @form = form
          @project = form.project
          @previous_department = form.previous_department
          @new_department = @project.departments
          @current_user = current_user
          @note = form.body
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :no_previous_department if project has no previous department.
        # - :invalid_state if project is a draft or was withdrawn by author.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?
          return broadcast(:no_previous_department) unless previous_department
          return broadcast(:invalid_state) if project.state == Decidim::Projects::Project::POSSIBLE_STATES::DRAFT ||
                                                    project.state == Decidim::Projects::Project::POSSIBLE_STATES::WITHDRAWN

          send_project_back_to_evaluator
          send_notification

          broadcast(:ok, project)
        end

        # private

        attr_reader :form, :project, :current_user, :note, :previous_department

        def send_project_back_to_evaluator
          @project = Decidim.traceability.perform_action!(
            :return_to_department,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.current_department_id = previous_department.id
            project.return_reason = note if note.present?
            project.save(validate: false)
            project.department_assignments.create(department: previous_department)
            project
          end
        end

        def send_notification
          return unless previous_department
          return if previous_department.coordinators.none?

          previous_department.coordinators.each do |user|
            EvaluationMailer.notify(project, 'return_to_department', current_user, user).deliver_later
          end
        end
      end
    end
  end
end
