# frozen_string_literal: true

# A form object used to create participatory processes from the admin dashboard.
Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm.class_eval do
  attribute :edition_year, Integer
  # dates
  attribute :project_editing_end_date, Decidim::Attributes::LocalizedDate # Do kiedy użytkownicy mogą edytować swoje projekty?
  attribute :withdrawn_end_date, Decidim::Attributes::LocalizedDate # Do kiedy użytkownicy mogą wycofywać swoje projekty?
  attribute :evaluation_start_date, Decidim::Attributes::LocalizedDate # Od kiedy można przydzielać projekty weryfikatorom?
  attribute :evaluation_end_date, Decidim::Attributes::TimeWithZone # Do kiedy koordynatorzy muszą zatwierdzić oceny?
  attribute :evaluation_publish_date, Decidim::Attributes::TimeWithZone # Data publikacji ocen
  attribute :evaluation_cards_submit_end_date, Decidim::Attributes::TimeWithZone # Do kiedy weryfikatorzy mogą oceniać projekty?
  attribute :appeal_start_date, Decidim::Attributes::TimeWithZone # Od kiedy użytkownicy mogą składać odwołania?
  attribute :appeal_end_date, Decidim::Attributes::TimeWithZone # Do kiedy użytkownicy mogą składać odwołania?
  attribute :reevaluation_cards_submit_end_date, Decidim::Attributes::LocalizedDate # Do kiedy weryfikatorzy moga robic ponowną ocenę
  attribute :reevaluation_end_date, Decidim::Attributes::LocalizedDate # Do kiedy koordynatorzy moga zatwierdzic ponowną ocenę
  attribute :reevaluation_publish_date, Decidim::Attributes::TimeWithZone # Data i godzina publikacji wyników ponownej oceny
  attribute :paper_project_submit_end_date, Decidim::Attributes::LocalizedDate # Do kiedy użytkownicy wewnętrzni mogą wprowadzać wersje papierowe projektów?
  attribute :paper_voting_submit_end_date, Decidim::Attributes::LocalizedDate # Do kiedy użytkownicy wewnętrzni mogą wprowadzać wersje papierowe kart do głosowania?
  attribute :status_change_notifications_sending_end_date, Decidim::Attributes::LocalizedDate # Do kiedy można wysyłać powiadomienia o zmianie statusu projektu?
  attribute :show_start_voting_button_at, Decidim::Attributes::TimeWithZone # Data i godzina pokazania przycisku do glosowania
  attribute :show_voting_results_button_at, Decidim::Attributes::TimeWithZone # Data i godzina pokazania przycisku do wynikow
  # limits for votings
  attribute :global_scope_projects_voting_limit, Integer # limit oddanych głosów na projekty ogólnomiejskie
  attribute :district_scope_projects_voting_limit, Integer # limit oddanych głosów na projekty dzielnicowe
  attribute :minimum_global_scope_projects_votes, Integer # wyamgana liczba głosów do zaciagniecia projektu ogólnomiejskiego na listę rankingową
  attribute :minimum_district_scope_projects_votes, Integer # wymagana liczba głosów do zaciagniecia projektu dzielnicowego na listę rankingową

  attribute :scope_budgets, [Decidim::ProcessesExtended::ScopeBudget]

  validates :edition_year, presence: true
  validates :project_editing_end_date, presence: true
  validates :withdrawn_end_date, presence: true
  validates :evaluation_start_date, presence: true
  validates :evaluation_end_date, presence: true
  validates :evaluation_publish_date, presence: true
  validates :appeal_start_date, presence: true
  validates :appeal_end_date, presence: true
  validates :reevaluation_cards_submit_end_date, presence: true
  validates :reevaluation_end_date, presence: true
  validates :reevaluation_publish_date, presence: true
  validates :paper_project_submit_end_date, presence: true
  validates :evaluation_cards_submit_end_date, presence: true
  validates :paper_voting_submit_end_date, presence: true
  validates :status_change_notifications_sending_end_date, presence: true
  validates :show_start_voting_button_at, presence: true
  validates :show_voting_results_button_at, presence: true
  validates :global_scope_projects_voting_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :district_scope_projects_voting_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :minimum_global_scope_projects_votes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :minimum_district_scope_projects_votes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # OVERWRITTEN DECIDIM METHOD
  # add init for scope_budgets
  def map_model(model)
    self.scope_budgets = model.scope_budgets

    self.scope_id = model.decidim_scope_id
    self.participatory_process_group_id = model.decidim_participatory_process_group_id
    self.related_process_ids = model.linked_participatory_space_resources(:participatory_process, "related_processes").pluck(:id)
    @processes = Decidim::ParticipatoryProcess.where(organization: model.organization).where.not(id: model.id)
  end
end