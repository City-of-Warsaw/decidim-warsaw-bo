# frozen_string_literal: true

module Decidim
  module CoreExtended
    # A command with all the business logic when a user duplicates a project.
    class DeleteProject < Rectify::Command

      # Public: Initializes the command.
      #
      # project
      # current_user - The current user
      def initialize(project, current_user)
        @project = project
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if there was no project
      # - :invalid if project was not a draft
      # - :invalid if project was was not authored by current user
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless project
        return broadcast(:invalid) unless project.state == Decidim::Projects::Project::POSSIBLE_STATES::DRAFT
        return broadcast(:invalid) unless project.created_by?(current_user)

        transaction do
          delete_project
        end

        broadcast(:ok)
      end

      private

      attr_reader :project, :current_user

      # delete project and all action logs for project
      def delete_project
        Decidim::ActionLog.where(resource_type: 'Decidim::Projects::Project', resource_id: project.id).delete_all
        project.destroy
      end
    end
  end
end
