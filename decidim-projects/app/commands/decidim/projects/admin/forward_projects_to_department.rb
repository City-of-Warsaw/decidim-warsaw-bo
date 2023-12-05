# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to forward many projects at once
      # to the different department.
      class ForwardProjectsToDepartment < Rectify::Command
        # Public: Initializes the command.
        #
        # component    - The component that contains the projects.
        # user         - the Decidim::User that is accepting changes.
        # project_ids  - the identifiers of the projects with the changes to be accepted.
        # department   - department
        def initialize(component, user, project_ids, department)
          @component = component
          @current_user = user
          @project_ids = project_ids
          @department = department
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are no projects.
        #
        # Method iterates through projects collection
        # and skips projects if project.current_department is
        # the same as the new department.
        #
        # If user is Admin, method allows forwarding to any department.
        # If user is Coordinator, method allows forwarding to departments
        # that are in association with User's own department
        #
        # Returns nothing.
        def call
          # return broadcast(:invalid) unless @evaluator # can also be unassigned
          return broadcast(:invalid) unless projects.any?
          return broadcast(:invalid) unless @department

          projects.each do |project|
            # skipping for department missmatch
            next if project.current_department == @department

            transaction do
              if current_user.ad_admin?
                forward_to_department(project)
              elsif current_user.ad_coordinator? && project.current_department == current_user.department && project.current_department&.departments&.include?(@department)
                forward_to_department(project)
              end
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :component, :current_user, :project_ids

        # Private: fetch projects
        #
        # returns collection of published projects
        def projects
          @projects ||= Decidim::Projects::Project
                        .published
                        .where(component: component)
                        .where(id: project_ids)
        end

        # Private: forward to department
        #
        # Method calls the command responsible for forwarding with proper data
        #
        # returns nothing
        def forward_to_department(project)
          Decidim::Projects::Admin::Evaluation::ForwardToDepartment.call(project, current_user, @department)
        end
      end
    end
  end
end
