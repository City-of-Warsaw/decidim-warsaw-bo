# frozen_string_literal: true

RSpec.shared_context 'with scopes and department for admin' do
  let!(:scope_om) do
    create(
      :scope,
      organization: organization,
      name: { "pl": 'Ogólnomiejski' },
      code: 'om',
      scope_type: scope_type_ogolnomiejski,
      department: create(:department),
      position: 1
    )
  end

  let!(:scope) do
    create(
      :scope,
      organization: organization,
      name: { 'pl' => 'Bielany' },
      code: 'bie',
      scope_type: scope_type_dzielnica,
      department: create(:department),
      position: 2
    )
  end

  let!(:scope_budget) do
    create(
      :scope_budget,
      participatory_process: part_process,
      scope: scope_om,
      budget_value: 10_000_000,
      max_proposal_budget_value: 1_000_000
    )
  end

  let!(:department) { create(:department) }
end
