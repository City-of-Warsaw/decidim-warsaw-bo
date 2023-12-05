# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user updates a vote.
    class UpdateVote < Rectify::Command
      include Decidim::Projects::VoteWizardHelper

      # Public: Initializes the command.
      #
      # project      - A project which is added or removed from votes_card
      # current_user - The current user or nil.
      def initialize(vote_card, project, current_user)
        @vote_card = vote_card
        @project = project
        @current_user = current_user
      end

      def call
        if ids = update_vote
          broadcast(:ok, ids)
        else
          broadcast(:invalid)
        end
      end

      private

      attr_reader :project, :vote_card, :current_user

      def update_vote
        ids = nil
        if project.is_district_project?
          projects_limit = 15
          return vote_card.projects.in_district_scope.pluck(:id) if vote_card.projects.in_district_scope.pluck(:id).count >= projects_limit && !vote_card.project_ids.include?(project.id)

          # Decidim::Projects::Project.where(id: @vote_card.projects.in_district_scope.pluck(:id))
          # all_projects = Decidim::Projects::Project.where(id: form.district_projects_ids)
          # .or(Decidim::Projects::Project.where(id: @vote_card.projects.in_global_scope.pluck(:id)))
          if vote_card.project_ids.include?(project.id)
            # usuwamy z listy
            vote_card.project_ids = vote_card.project_ids - [project.id]
          else
            # dodajemy do listy
            vote_card.project_ids = vote_card.project_ids + [project.id]
          end
          ids = vote_card.projects.in_district_scope.pluck(:id)


        elsif project.is_global_project?
          projects_limit = 10
          return vote_card.projects.in_global_scope.pluck(:id) if vote_card.projects.in_global_scope.pluck(:id).count >= projects_limit && !vote_card.project_ids.include?(project.id)

          # all_projects = Decidim::Projects::Project.where(id: form.global_projects_ids)
          # .or(Decidim::Projects::Project.where(id: @vote_card.projects.in_district_scope.pluck(:id)))
          if vote_card.project_ids.include?(project.id)
            # usuwamy z listy
            return vote_card.project_ids = vote_card.project_ids - [project.id]
          else
            # dodajemy do listy
            return vote_card.project_ids = vote_card.project_ids + [project.id]
          end
          ids = vote_card.projects.in_global_scope.pluck(:id)
        end
        ids
      end


    end
  end
end
