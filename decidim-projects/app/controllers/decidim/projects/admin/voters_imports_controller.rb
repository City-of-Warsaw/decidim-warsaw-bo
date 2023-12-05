# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows clear and import possible voters list from CSV
  class Admin::VotersImportsController < Decidim::Admin::ApplicationController
    include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin

    def new
      enforce_permission_to :create, :voters_import
      @form = Decidim::Projects::Admin::VotersImportForm.new
      @last_import_date = Decidim::Projects::Voter.last&.created_at
      @last_import_size = Decidim::Projects::Voter.count
    end

    # Imports voters (pesel, first,name, last_name), for votes verification
    def create
      enforce_permission_to :create, :voters_import
      @form = form(Decidim::Projects::Admin::VotersImportForm).from_params(params)

      Admin::ImportVoters.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("voters.create.success", scope: "decidim.projects.admin")
          redirect_to decidim_admin_participatory_processes.new_voters_imports_path(current_participatory_space)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("voters.create.invalid", scope: "decidim.projects.admin")
          render action: "new"
        end
      end
    end

  end
end
