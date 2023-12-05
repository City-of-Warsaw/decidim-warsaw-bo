# frozen_string_literal: true

module Decidim
  module Projects
    # A class used to find the vote cards for user with permissions.
    class UserVoteCards < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that gets votes
      # component - projects edition
      def self.for(user, component, project = nil)
        new(user, component, project).query
      end

      def initialize(user, component, project)
        @user = user
        @component = component
        @project = project
      end

      def query
        if project
          find_vote_cards_for_user.
            joins(:project_votes).
            where("decidim_projects_project_votes.decidim_projects_project_id": project.id).without_sent
        else
          find_vote_cards_for_user
        end
      end

      def find_vote_cards_for_user
        vote_cards = VoteCard.where(component: component)
        return vote_cards if user.ad_admin?

        if user.ad_coordinator? && user.assigned_scope_id
          # coordinator can see paper votes that need acceptance or are submitted, but not after verification
          vote_cards.paper_votes.where('decidim_projects_vote_cards.scope_id': user.assigned_scope_id).for_coordinators
        elsif user.ad_editor?
          # editor can see only votes he added and as long as they were not accepted
          vote_cards.paper_votes.where(author_id: user.id).waiting_votes
        else
          # for coordinators from departments that are not assigned to scope
          VoteCard.none
        end
      end

      private

      attr_reader :user, :component, :project
    end
  end
end
