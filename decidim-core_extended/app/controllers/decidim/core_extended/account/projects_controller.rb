# frozen_string_literal: true

module Decidim
  module CoreExtended
    module Account
      class ProjectsController < Decidim::CoreExtended::ApplicationController
        include Decidim::UserProfile
        helper Decidim::ResourceHelper
        layout 'decidim/core_extended/user_profile'

        helper_method :latest_edition_coauthored_projects,
                      :archive_projects,
                      :coauthored_projects,
                      :my_projects,
                      :archive_coauthored_projects,
                      :latest_edition

        def index; end

        def duplicate
          @project = current_user.projects.find_by(id: params[:id])

          Decidim::CoreExtended::DuplicateProject.call(@project, current_user, projects_component) do
            on(:ok) do
              flash[:notice] = 'Utworzono kopię roboczą na podstawie projektu'
              redirect_to account_projects_path
            end

            on(:invalid) do
              flash[:alert] = 'Nie udało sie utworzyć nowego projektu'
              redirect_to account_projects_path
            end
          end
        end

        def destroy
          @project = current_user.projects.where(state: 'draft').find_by(id: params[:id])

          Decidim::CoreExtended::DeleteProject.call(@project, current_user) do
            on(:ok) do
              redirect_to account_projects_path, notice: 'Projekt został usunięty'
            end

            on(:invalid) do
              redirect_to account_projects_path, error: 'Nie udało się usunać projektu'
            end
          end
        end

        private

        def my_projects
          @my_projects ||= current_user.authored_projects.joins(:component)
        end

        def latest_edition_coauthored_projects
          @latest_edition_coauthored_projects ||= current_user.coauthored_projects.joins(:component).where('decidim_components.participatory_space_id': latest_edition.id)
        end

        def coauthored_projects
          @coauthored_projects ||= current_user.coauthored_projects.joins(:component)
        end

        def archive_projects
          @archive_authored_projects ||= current_user.authored_projects.joins(:component).where.not('decidim_components.participatory_space_id': latest_edition.id)
        end

        def archive_coauthored_projects
          @archive_coauthored_projects ||= current_user.coauthored_projects.joins(:component).where.not('decidim_components.participatory_space_id': latest_edition.id)
        end

        def latest_edition
          @latest_edition ||= ::Current.actual_edition
        end

        def projects_component
          @projects_component ||= latest_edition.published_project_component
        end
      end
    end
  end
end