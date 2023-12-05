# frozen_string_literal: true

module Decidim
  module Projects
    # ProjectRank is a model that holds all the data from voting that is connected to the project.
    # Once the voting process is over, Administrator can generate Project Ranks for all the projects
    class ProjectRank < ApplicationRecord
      enum status: { on_the_list: 'on_the_list', excluded_by_conflict: 'excluded_by_conflict' }

      belongs_to :scope,
                 class_name: 'Decidim::Scope',
                 foreign_key: :scope_id,
                 optional: true
      belongs_to :project,
                 class_name: 'Decidim::Projects::Project',
                 foreign_key: :project_id
      scope :within_minimum_votes_limit, -> { where(votes_limit_reached: true) }
      scope :not_on_the_list, -> { where(status: nil).or(where(status: 'excluded_by_conflict')) }
      scope :for_scope, ->(scope) { where('decidim_projects_project_ranks.scope_id': scope.id) }
      scope :default_sort, lambda {
        joins('JOIN decidim_projects_projects ON decidim_projects_projects.id = decidim_projects_project_ranks.project_id')
                              .order('decidim_projects_project_ranks.valid_votes_count': :desc)
                               .order('decidim_projects_project_ranks.invalid_votes_count': :desc)
                              .order('LOWER("decidim_projects_projects"."title"::TEXT) DESC')
                           }
      scope :sorted_by_valid_votes_count, -> { order('decidim_projects_project_ranks.valid_votes_count': :desc) }

      def conflict_on_rank_list
        project.projects_in_conflict.on_ranking_list
      end

      def self.log_presenter_class_for(_log)
        Decidim::Projects::AdminLog::ProjectRankPresenter
      end
    end
  end
end
