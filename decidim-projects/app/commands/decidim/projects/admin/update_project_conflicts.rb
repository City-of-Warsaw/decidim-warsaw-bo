# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when user adds conflicted projects
    class UpdateProjectConflicts < Rectify::Command

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      def initialize(form)
        @form = form
        @project = form.project
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless project
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_project_conflicts
        end

        broadcast(:ok, project)
      end

      private

      attr_reader :form, :project

      # Private method updating projects
      #
      # returns nothing
      def update_project_conflicts
        conflicts_ids_to_remove = project.projects_in_conflict.pluck(:id) - form.conflicted_projects.pluck(:id) # to keep the same type of data
        project_id = project.id

        project.projects_in_conflict = form.conflicted_projects

        # Adding mirrored association
        form.conflicted_projects.each do |proj|
          all_added_projects_ids = proj.projects_in_conflict.pluck(:id) + [project_id]
          proj.projects_in_conflict = Decidim::Projects::Project.where('decidim_projects_projects.id': all_added_projects_ids)
        end

        if project.projects_in_conflict.size > 0
          # we have conflicts with some projects, so we need decision or we set "waiting for decision"
          project.update_column('conflict_status', form.conflict_status.presence || Decidim::Projects::Project.conflict_statuses[:waiting])
        else
          # we do not have conflicts with any projects - "conflicts are not set"
          project.update_column('conflict_status', Decidim::Projects::Project.conflict_statuses[:no_conflicts])
        end

        # Clearing mirrored association
        Decidim::Projects::ProjectConflict.where(second_project_id: project_id).where(project_id: conflicts_ids_to_remove).destroy_all
      end
    end
  end
end
