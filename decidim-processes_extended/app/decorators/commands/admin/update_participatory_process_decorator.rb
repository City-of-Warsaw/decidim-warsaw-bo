# frozen_string_literal: true

# A command with all the business logic when creating a new participatory process in the system.
Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.class_eval do

  private

  # OVERWRITTEN DECIDIM METHOD
  # update scope budgets for process during process update
  def update_participatory_process
    Decidim::Organization.first.touch # Fix Hero cache

    @participatory_process.assign_attributes(attributes)
    return unless @participatory_process.valid?

    @participatory_process.save!

    # aktualizacja budzetow w dzielnicach
    # "scope_budgets"=>[{"id"=>"67", "budget_value"=>"1"}
    form[:scope_budgets].each do |sb|
      transaction do
        b = Decidim::ProcessesExtended::ScopeBudget.find sb[:id]
        b.update_columns(
          budget_value: sb[:budget_value],
          max_proposal_budget_value: sb[:max_proposal_budget_value]
        )
      end
    end

    Decidim.traceability.perform_action!(:update, @participatory_process, form.current_user) do
      @participatory_process
    end
    link_related_processes
  end

  def attributes
    {
      title: form.title,
      subtitle: form.subtitle,
      weight: form.weight,
      slug: form.slug,
      hashtag: form.hashtag,
      promoted: form.promoted,
      description: form.description,
      short_description: form.short_description,
      scopes_enabled: form.scopes_enabled,
      scope: form.scope,
      scope_type_max_depth: form.scope_type_max_depth,
      private_space: form.private_space,
      developer_group: form.developer_group,
      local_area: form.local_area,
      area: form.area,
      target: form.target,
      participatory_scope: form.participatory_scope,
      participatory_structure: form.participatory_structure,
      meta_scope: form.meta_scope,
      start_date: form.start_date,
      end_date: form.end_date,
      participatory_process_group: form.participatory_process_group,
      show_metrics: form.show_metrics,
      show_statistics: form.show_statistics,
      announcement: form.announcement,
      edition_year: form.edition_year,
      # special dates
      project_editing_end_date: form.project_editing_end_date,
      withdrawn_end_date: form.withdrawn_end_date,
      evaluation_start_date: form.evaluation_start_date,
      evaluation_end_date: form.evaluation_end_date,
      evaluation_publish_date: form.evaluation_publish_date,
      appeal_start_date: form.appeal_start_date,
      appeal_end_date: form.appeal_end_date,
      reevaluation_cards_submit_end_date: form.reevaluation_cards_submit_end_date,
      reevaluation_end_date: form.reevaluation_end_date,
      reevaluation_publish_date: form.reevaluation_publish_date,
      paper_project_submit_end_date: form.paper_project_submit_end_date,
      evaluation_cards_submit_end_date: form.evaluation_cards_submit_end_date,
      paper_voting_submit_end_date: form.paper_voting_submit_end_date,
      status_change_notifications_sending_end_date: form.status_change_notifications_sending_end_date,
      show_start_voting_button_at: form.show_start_voting_button_at,
      show_voting_results_button_at: form.show_voting_results_button_at,
      # values for voting validations
      global_scope_projects_voting_limit: form.global_scope_projects_voting_limit,
      district_scope_projects_voting_limit: form.district_scope_projects_voting_limit,
      minimum_global_scope_projects_votes: form.minimum_global_scope_projects_votes,
      minimum_district_scope_projects_votes: form.minimum_district_scope_projects_votes
    }.merge(uploader_attributes)
  end

end
