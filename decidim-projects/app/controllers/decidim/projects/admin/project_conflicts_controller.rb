# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing projects conflicts actions in admin panel.
      class ProjectConflictsController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        helper_method :project, :projects_in_potential_conflict

        def index
          enforce_permission_to :manage, :project_conflict

          @conflicted_projects = project.projects_in_conflict.on_ranking_list
          # render 'decidim/projects/admin/ranking_lists/index'
        end

        def edit
          enforce_permission_to :manage, :project_conflict

          @form = form(Decidim::Projects::Admin::ProjectConflictForm).from_model(project)
        end

        def update
          enforce_permission_to :manage, :project_conflict

          @form = form(Decidim::Projects::Admin::ProjectConflictForm).from_params(
            params[:project_conflict].merge(project_id: params[:project_id])
          )

          Decidim::Projects::Admin::UpdateProjectConflicts.call(@form) do
            on(:ok) do
              flash[:notice] = "Dodano wykluczające się projekty"
              redirect_to projects_path
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się dodać wykluczajaćych się projektów."
              render :edit
            end
          end
        end

        private

        def project
          @project ||= Decidim::Projects::Project.find_by(id: params[:project_id])
        end

        def projects_in_potential_conflict
          @projects_in_potential_conflict ||= project.projects_in_potential_conflict
        end
      end
    end
  end
end
