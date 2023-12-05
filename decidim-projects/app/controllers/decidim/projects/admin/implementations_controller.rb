# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing implementations in admin panel.
      class ImplementationsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Projects::Admin::ImplementationsFilterable
        include Decidim::Projects::Admin::ProjectsFilteredCollection

        include Decidim::FormFactory

        helper_method :projects, :query, :form_presenter, :project, :project_ids
        helper Projects::Admin::ProjectBulkActionsHelper
        helper Decidim::Admin::FilterableHelper
        helper Projects::Admin::ProjectsHelper

        def index
          enforce_permission_to :index, :implementations
        end

        def export
          enforce_permission_to :index, :implementations
          @projects = collection.includes(:component, :implementation_photos, :scope => :scope_type)

          respond_to do |format|
            format.xlsx {
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=realizacje-#{edition_year}.xlsx"
            }
          end
        end

        def show
          project
          enforce_permission_to :implementation, :project, project: @project
          @form = form(Decidim::Projects::Admin::ImplementationForm).from_model(project)
        end

        def create
          @project = collection.find(params[:project_id])
          enforce_permission_to :implementation, :project, project: @project

          @form = form(Decidim::Projects::Admin::ImplementationForm).from_params(params[:implementation].merge(user: current_user, project_id: @project.id))

          Decidim::Projects::Admin::Implementation::CreateImplementation.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("implementations.create.success", scope: "decidim.projects.admin")
              redirect_to implementation_path(@project)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("implementations.create.invalid", scope: "decidim.projects.admin")
              render action: "show"
            end
          end
        end

        def edit
          @implementation = Decidim::Projects::Implementation.find(params[:id])
          enforce_permission_to :edit_implementation, :project, project: @implementation.project

          @form = form(Decidim::Projects::Admin::ImplementationEditForm).from_model(@implementation)
        end

        def update
          @implementation = Decidim::Projects::Implementation.find(params[:id])
          enforce_permission_to :edit_implementation, :project, project: @implementation.project

          @form = form(Decidim::Projects::Admin::ImplementationEditForm).from_params(params[:implementation].merge(project_id: @implementation.project_id))

          Decidim::Projects::Admin::Implementation::UpdateImplementation.call(@form, @implementation, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("implementations.create.success", scope: "decidim.projects.admin")
              redirect_to implementation_path(@implementation.project)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("implementations.create.invalid", scope: "decidim.projects.admin")
              render action: "edit"
            end
          end
        end

        def edit_alt
          @project = collection.find(params[:project_id])
          enforce_permission_to :edit, :project, project: @project

          @implementation_photo = Decidim::Projects::ImplementationPhoto.find(params[:id])
          @form = form(Decidim::Projects::Admin::ImplementationPhotoForm).from_model(@implementation_photo)
        end

        def alt
          @project = collection.find(params[:project_id])
          enforce_permission_to :edit, :project, project: @project

          @implementation_photo = Decidim::Projects::ImplementationPhoto.find(params[:id])
          @form = form(Decidim::Projects::Admin::ImplementationPhotoForm).from_params(params[:implementation_photo].merge(model: @implementation_photo))

          Decidim::Projects::Admin::Implementation::UpdateAlt.call(@form, @project, current_user) do
            on(:ok) do
              flash[:notice] = 'Uaktualniono opis alternatywny zdjęcia'
              redirect_to implementation_path(id: params[:project_id])
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się aualtualnić opisu alternatywnego'
              render action: "edit_alt"
            end
          end
        end

        private


        def collection
          @collection ||= collection_filtered_by_user_permission.implementations
        end

        def projects
          @projects ||= filtered_collection
        end

        def project
          @project ||= collection.find(params[:id])
        end
      end
    end
  end
end
