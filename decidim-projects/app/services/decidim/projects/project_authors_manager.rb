# frozen_string_literal: true

module Decidim
  module Projects
    class ProjectAuthorsManager

      def initialize(project)
        @project = project
      end

      # Add author to project
      # ProjectAuthorsManager.new(project).add_author(@current_user)
      def add_author(user)
        @project.add_coauthor(user, confirmation_status: 'confirmed', coauthorship_acceptance_date: Date.current)
      end

      # Add coauthor to project, check if user already is one of project's coauthors
      # ProjectAuthorsManager.new(project).add_coauthor(@current_user)
      def add_coauthor(user)
        return if @project.authored_by?(user)

        @project.add_coauthor(user, coauthor: true)
      end

      # Find or create coauthor for project
      # ProjectAuthorsManager.new(project).create_coauthor()
      def create_coauthor(email, user_params = {})
        organization = @project.organization
        normal_user = Decidim::CreateNormalUser.new(email, organization, user_params).find_or_create
        return unless normal_user
        return normal_user if @project.authored_by?(normal_user)

        @project.add_coauthor(normal_user, coauthor: true)
        normal_user
      end

      def author
        @project.creator_author
      end

      def coauthors
        @project.coauthors
      end
    end
  end
end
