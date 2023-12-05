# frozen_string_literal: true

module Decidim
  module Projects
    # A presenter to get the url or path for project
    class ProjectLocatorPresenter
      def initialize(project)
        @project = project
      end

      attr_reader :project

      def path(options = {})
        route_proxy.project_path(project, options)
      end

      def edit
        if project.any_draft?
          route_proxy.edit_draft_projects_wizard_path(project)
        else
          route_proxy.edit_projects_wizard_path(project)
        end
      end

      def withdraw
        route_proxy.withdraw_projects_wizard_path(project)
      end

      def component
        project.component
      end

      def route_proxy
        @route_proxy ||= EngineRouter.main_proxy(component)
      end
    end
  end
end