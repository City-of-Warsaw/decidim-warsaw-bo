# frozen_string_literal: true

# Controller that allows managing participatory processes.
Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController.class_eval do

  def start_voting
    enforce_permission_to :start_voting, :start_voting, process: current_participatory_process
    Decidim::ProcessesExtended::Admin::StartVotingProcess.call(current_participatory_process, current_user) do
      on(:ok) do |participatory_process|
        flash[:notice] = I18n.t("participatory_processes.voting_started.success", scope: "decidim.admin")
      end

      on(:invalid) do
        flash[:alert] = I18n.t("participatory_processes.voting_started.error", scope: "decidim.admin")
      end

      redirect_to projects_path(current_participatory_process)
    end
  end

  private

  # OVERWRITTEN DECIDIM METHOD
  # Scopes selection changed
  def collection
    @collection ||= Decidim::ParticipatoryProcess.all.order(edition_year: :desc)
  end

  def projects_path(process)
    component = process.projects_component
    if component
      decidim_admin_participatory_process_projects_path(participatory_process_slug: process, component_id: component.id)
    else
      edit_participatory_process_path(process)
    end
  end
end