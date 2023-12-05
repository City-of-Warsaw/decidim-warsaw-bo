# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # Draws voting_number for projects on ranking lists, for voting process
    class GenerateVotingNumbers < Rectify::Command

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # component - projects component
      def initialize(component, current_user)
        @current_user = current_user
        @projects_component = component
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # Returns nothing.
      def call
        transaction do
          clean_projects_for_voting
          setup_projects_for_voting
          generate_voting_numbers
        end

        broadcast(:ok)
      end

      private

      attr_reader :current_user, :projects_component

      def setup_projects_for_voting
        accepted_projects.each do |project|
          # votes_count moze byc 0 jako default, ale sprawdzic import z Assecco
          project.update_columns(chosen_for_voting: true, votes_count: 0)
        end
      end

      def generate_voting_numbers
        Decidim::Scope.all.each do |scope|
          generate_numbers_for_scope(scope)
        end
      end

      # generate voting_numbers for scope
      def generate_numbers_for_scope(scope)
        projects_in_scope = Decidim::Projects::ProjectsForVoting.for(projects_component).where(decidim_scope_id: scope.id)
        return if projects_in_scope.size.zero?

        shuffled_ranking_numbers = [*1..projects_in_scope.size].shuffle
        projects_in_scope.each_with_index do |project, i|
          project.update_column(:voting_number, shuffled_ranking_numbers[i])
        end
      end

      # remove all projects from voting list, clean voting numbers and votes counters
      def clean_projects_for_voting
        Decidim::Projects::ProjectsFromEdition.for(projects_component).update_all(chosen_for_voting: false,
                                                                                  votes_count: nil,
                                                                                  voting_number: nil)
      end

      def accepted_projects
        @accepted_projects ||= Decidim::Projects::ProjectsFromEdition.for(projects_component).accepted
      end
    end
  end
end
