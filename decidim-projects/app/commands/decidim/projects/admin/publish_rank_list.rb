# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when a user creates a new vote.
    class PublishRankList < Rectify::Command

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # current_space - ParticipatorySpace (Process)
      def initialize(current_user, current_space)
        @current_user = current_user
        @current_space = current_space
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # Returns nothing.
      def call
        transaction do
          update_projects_statuses(projects)
          activate_results_step
          show_voting_results_button
        end
        send_notifications

        broadcast(:ok)
      end

      private

      attr_reader :current_user

      def projects
        @projects ||= Decidim::Projects::ProjectsForVoting.new(@current_space.projects_component).query
      end

      def show_voting_results_button
        @current_space.update_column(:show_voting_results_button_at, DateTime.current)
      end

        # Updating statuses based on the presence of teh project on the ranking list
      def update_projects_statuses(projects)
        projects.each do |project|
          project.project_rank.on_the_list? ? project.selected! : project.not_selected!
        end
      end

      # Activating results step if it wasn't activated earlier
      # Activating voting step
      def activate_results_step
        @current_space.steps.update_all(active: false)
        @current_space.results_step&.update!(active: true)
      end

      def send_notifications
        # # To ensure that new statuses were loaded
        # projects.reload
        #
        # projects.each do |project|
        #   if project.selected? || project.not_selected?
        #     project.authors.each do |user|
        #       Decidim::Projects::ProjectVotingEndedJob.perform_later(
        #         project,
        #         user.email,
        #         project.selected? ? 'winning_project' : 'loosing_project')
        #     end
        #   end
        # end

        Rails.logger.info "Wysyslam maiin o wynikach"
        Decidim::Projects::ProjectVotingEndedJob.perform_later(@current_space.projects_component)
      end
    end
  end
end
