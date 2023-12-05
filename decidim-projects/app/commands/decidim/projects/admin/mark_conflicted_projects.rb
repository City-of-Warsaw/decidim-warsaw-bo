# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when admin mark all conflicted projects
    class MarkConflictedProjects < Rectify::Command

      # Public: Initializes the command.
      def initialize(projects_component, user)
        @projects_component = projects_component
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      #
      # Returns nothing.
      def call
        transaction do
          reset_conflicts
          mark_conflicted_projects
        end

        broadcast(:ok)
      end

      private

      # It marks if project is in conflict with others or not,
      # if it has other conflicted projects User should check it, and next do it by him self
      def mark_conflicted_projects
        Decidim::Projects::ProjectsForVoting.new(@projects_component).query.find_each do |project|
          if project.projects_in_potential_conflict.none?
            project.update_column('conflict_status', Decidim::Projects::Project.conflict_statuses[:no_conflicts])
          else
            project.update_column('conflict_status', Decidim::Projects::Project.conflict_statuses[:waiting])

            project.projects_in_conflict = project.projects_in_potential_conflict

            # project.projects_in_potential_conflict.each do |proj|
            #   # Adding mirrored association
            #   already_added_projects_ids = proj.projects_in_conflict.pluck(:id) + [project.id]
            #   proj.projects_in_conflict = Decidim::Projects::Project.where('decidim_projects_projects.id': already_added_projects_ids)
            # end
          end
        end
      end

      def reset_conflicts
        Decidim::Projects::ProjectsFromEdition.for(@projects_component).update_all(conflict_status: 'not_set')
        project_ids = Decidim::Projects::ProjectsFromEdition.for(@projects_component).pluck(:id)
        Decidim::Projects::ProjectConflict.where(project_id: project_ids).delete_all
        Decidim::Projects::ProjectConflict.where(second_project_id: project_ids).delete_all
      end
    end
  end
end
