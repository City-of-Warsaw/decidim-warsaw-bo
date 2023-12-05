# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that handles all the ranking list actions
      class RankingListsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Projects::Admin::RankingListFilterable

        before_action :initialize_search_params

        helper_method :project_ranks, :scope

        def index
          enforce_permission_to :read, :ranking_list

          @budget_value = current_participatory_space.scope_budgets.find_by(decidim_scope_id: scope.id)&.budget_value
          @projects_total_budget_value =  project_ranks.on_the_list.joins(:project).sum('decidim_projects_projects.budget_value')

          # Logging action needs to have resource - for show/list its first/any item
          create_log(project_ranks.first, :ranking_list_index) if project_ranks.any?
        end

        # Generate ranking list
        def generate_ranks
          enforce_permission_to :read, :ranking_list

          Decidim::Projects::Admin::GenerateRankingLists.call(current_user, current_component) do
            on(:ok) do |_project|
              flash[:notice] = 'Wygenerowano liste'
            end

            on(:conflicts_remaining) do
              flash[:alert] = 'Nie wszystkie konflikty zostały potwierdzone'
            end
            on(:invalid) do
              flash[:alert] = 'Nie udało się wygenerować listy, spróbuj ponownie'
            end
          end
          redirect_to ranking_lists_path
        end

        def publish
          enforce_permission_to :read, :ranking_list

          Decidim::Projects::Admin::PublishRankList.call(current_user, current_participatory_space) do
            on(:ok) do |_project|
              # Logging action needs to have resource - for show/list its first/any item
              create_log(projects_for_voting.first, :publish_ranking_list) if projects_for_voting.any?

              flash[:notice] = 'Opublikowano liste rankingową.'
            end

            on(:invalid) do
              flash[:alert] = 'Nie udało się opublikować listy rankingowej, spróbuj ponownie'
            end
          end
          redirect_to ranking_lists_path
        end

        def clear_vote_cards
          enforce_permission_to :read, :ranking_list

          Decidim::Projects::Admin::ClearVoteCards.call(current_user) do
            on(:ok) do |_project|
              flash[:notice] = 'Karty do głosowania zostaly usunięte'
            end
          end
          redirect_to ranking_lists_path
        end

        # Export votes to CSV, Excel, JSON
        # params[:id] - scope for exported projects
        def export
          # Logging action needs to have resource - for show/list its first/any item
          create_log(collection.first, :export_ranking_list) if collection.any?

          scope = Decidim::Scope.find params[:id]
          ExportRankingListJob.perform_later(current_user, current_component, 'ranking_list', params[:format], scope)

          flash[:notice] = t('decidim.admin.exports.notice')
          redirect_to ranking_lists_path
        end

        private
        def create_log(resource, log_type)
          Decidim::ActionLogger.log(
            log_type,
            current_user,
            resource,
            nil,
            { visibility: 'admin-only',
              component: { "title": current_component.name, "manifest_name": current_component.manifest_name },
              participatory_space: { "title": current_participatory_space.title, manifest_name: current_participatory_space.manifest.name } }
          )
        end

        def projects_for_voting
          Decidim::Projects::ProjectsForVoting.new(current_component).query
        end

        # find selected scope, if none was choosen then global scope is set as default
        # return Decidim::Scope
        def scope
          @scope ||= begin
                       scope_id = params.dig(:q, :scope_id_eq)
                       Decidim::Scope.find_by(id: scope_id)
                     end
        end

        def collection
          @collection ||= Decidim::Projects::ProjectRank.for_scope(scope).where(project_id: projects_for_voting.pluck(:id)).default_sort
        end

        # Private: filters collection of project_ranks
        def project_ranks
          @project_ranks ||= filtered_collection.includes(:project, :scope).except(:limit, :offset)
        end

        def initialize_search_params
          params[:q] = {} if params[:q].blank?

          # init default sorting
          # params[:q][:s] = 'valid_votes_count desc' if params[:q][:s].blank?
          # params[:q][:s] = 'valid_votes_count desc,percentage_of_not_verified_votes desc' if params[:q][:s].blank?
          # init default scope to global
          params[:q][:scope_id_eq] = Decidim::Projects::Project::GLOBAL_SCOPE_ID if params[:q][:scope_id_eq].blank?
        end
      end
    end
  end
end
