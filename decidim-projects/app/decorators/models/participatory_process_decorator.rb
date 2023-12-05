# frozen_string_literal: true

# Interaction between a user and an organization is done via a
# ParticipatoryProcess. It's a unit of action from the Organization point of
# view that groups several components (proposals, debates...) distributed in
# steps that get enabled or disabled depending on which step is currently
# active.
Decidim::ParticipatoryProcess.class_eval do
  Decidim::ParticipatoryProcess::DEFAULT_STEPS_SYSTEM_NAMES = %i[submitting rating voting results realization]

  has_many :scope_budgets,
           class_name: 'Decidim::ProcessesExtended::ScopeBudget',
           foreign_key: 'decidim_participatory_process_id',
           dependent: :delete_all

  has_one :project_customization,
          class_name: 'Decidim::Projects::ProjectCustomization',
          foreign_key: 'decidim_participatory_process_id',
          dependent: :destroy

  has_one :endorsement_list_setting,
          class_name: 'Decidim::ProcessesExtended::EndorsementListSetting',
          foreign_key: 'decidim_participatory_process_id',
          dependent: :destroy

  scope :last_editions, -> (organization_id) { published.where(decidim_organization_id: organization_id).order(created_at: :desc) }
  scope :editions_with_votes, -> (organization_id) { published.order(edition_year: :desc) }

  # Return actual process
  def self.actual_edition
    Current.actual_edition
  end

  # Return last edition with voting stage
  def self.find_edition_with_votes(organization)
    Decidim::ParticipatoryProcess.editions_with_votes(organization).first
  end

  # return value for max project budget
  def limit_for_scope(scope)
    scope_budgets.find_by(decidim_scope_id: scope.id)&.max_proposal_budget_value
  end

  def budget_value_for(scope)
    scope_budgets.find_by(decidim_scope_id: scope.id)&.budget_value
  end

  # Public: Checks whether the process is inside the time window to submit appeal.
  #
  # returns Boolean
  def time_for_appeals?
    return unless appeal_start_date
    return unless appeal_end_date

    appeal_start_date <= DateTime.current && DateTime.current <= appeal_end_date && evaluation_publish_date <= DateTime.current
  end

  def time_for_voting?
    return false unless voting_step
    return false unless voting_step == active_step # has to be active

    voting_step.active_step?
  end

  def time_for_posters?
    return false unless voting_step

    voting_step == active_step # has to be active
  end

  def ready_to_start_voting?
    return false unless reevaluation_publish_date
    return false unless voting_step
    return false unless voting_step.end_date # fix when date is blank
    return false if voting_step == active_step # already activated

    reevaluation_publish_date <= Date.current && Date.current < voting_step.end_date
  end

  def submitting_step
    steps.find_by(system_name: 'submitting')
  end

  def evaluation_step
    steps.find_by(system_name: 'rating')
  end

  def voting_step
    steps.find_by(system_name: 'voting')
  end

  def results_step
    steps.find_by(system_name: 'results')
  end

  def projects_component
    components.find_by(manifest_name: 'projects')
  end

  def published_project_component
    components.published.find_by(manifest_name: 'projects')
  end
end
