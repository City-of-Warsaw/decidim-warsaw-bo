# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows managing project forms in admin panel.
  class Admin::ProjectFormsController < Decidim::Admin::ApplicationController
    helper Decidim::Projects::Admin::ProjectsHelper
    helper Decidim::Projects::Admin::ProjectsCustomizationHelper
    include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin

    def edit
      enforce_permission_to :read_form, :projects
      @project_customization = set_project_customization

      @form = form(Decidim::Projects::Admin::ProjectCustomizationForm).from_model(@project_customization)
    end

    def update
      @project_customization = set_project_customization
      @form = form(Decidim::Projects::Admin::ProjectCustomizationForm).from_params(params[:project_customization])

      Decidim::Projects::Admin::CreateProjectCustomization.call(@form, current_user, current_participatory_space, @project_customization) do
        on(:ok) do
          flash[:notice] = "Zapisano zmiany w formualarzu"
          redirect_to decidim_admin_participatory_processes.edit_project_form_path(current_participatory_space)
        end

        on(:invalid) do
          flash.now[:alert] = "Nie udało się zapisać zmian w formularzu"
          render action: "edit"
        end
      end
    end

    private

    def set_project_customization
      current_participatory_space.project_customization ||
        Decidim::Projects::ProjectCustomization.new(process: Decidim::ParticipatoryProcess.last, custom_names: {}, additional_attributes: [{}])
    end
  end
end
