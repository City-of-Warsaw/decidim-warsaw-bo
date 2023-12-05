# frozen_string_literal: true

module Decidim
  module Projects
    # Controller that allows to manage poster templates in admin pandel.
    module Admin
      class PosterTemplatesController < Decidim::Admin::ApplicationController
        include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin

        helper Decidim::ResourceHelper
        helper Decidim::Projects::Admin::ProjectsHelper

        helper_method :poster_template, :poster_templates

        def index
          enforce_permission_to :manage, :poster_template
        end

        def show
          enforce_permission_to :manage, :poster_template
        end

        def new
          enforce_permission_to :manage, :poster_template
          @form = form(Admin::PosterTemplateForm).instance
        end

        def create
          enforce_permission_to :manage, :poster_template
          @form = form(Decidim::Projects::Admin::PosterTemplateForm).from_params(params)

          Admin::CreatePosterTemplate.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t('poster_templates.create.success', scope: 'decidim.projects.admin')
              redirect_to decidim_admin_participatory_processes.poster_template_path(current_participatory_space, @poster_template)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('poster_templates.create.errors', scope: 'decidim.projects.admin')
              render action: 'new'
            end
          end
        end

        def edit
          enforce_permission_to :manage, :poster_template
          @form = form(Admin::PosterTemplateForm).from_model(poster_template)
        end

        def update
          enforce_permission_to :manage, :poster_template
          @form = form(Decidim::Projects::Admin::PosterTemplateForm).from_params(params)

          Admin::UpdatePosterTemplate.call(poster_template, @form) do
            on(:ok) do
              flash[:notice] = I18n.t('poster_templates.update.success', scope: 'decidim.projects.admin')
              redirect_to decidim_admin_participatory_processes.poster_template_path(current_participatory_space, poster_template)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('poster_templates.update.errors', scope: 'decidim.projects.admin')
              render action: 'edit'
            end
          end
        end

        def destroy
          enforce_permission_to :manage, :poster_template
          poster_template.destroy!
          flash[:notice] = I18n.t('poster_templates.destroy.success', scope: 'decidim.projects.admin')
          redirect_to decidim_admin_participatory_processes.poster_templates_path(current_participatory_space)
        end

        private

        def base_query
          poster_templates
        end

        def poster_template
          @poster_template ||= PosterTemplate.find_by(id: params[:id])
        end

        def poster_templates
          Decidim::Projects::PosterTemplate.where(process: current_participatory_space)
        end
      end
    end
  end
end
