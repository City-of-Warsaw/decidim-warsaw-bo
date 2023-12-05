# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :processes_extended_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :processes_extended).i18n_name }
    manifest_name { :processes_extended }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :scope_budget, class: Decidim::ProcessesExtended::ScopeBudget do
    participatory_process
    scope
    budget_value { 10_000_000 }
    max_proposal_budget_value { 1_000_000 }
  end
end
