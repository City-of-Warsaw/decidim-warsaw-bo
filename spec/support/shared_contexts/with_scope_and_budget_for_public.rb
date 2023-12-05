# frozen_string_literal: true

RSpec.shared_context 'with scope and budget for public' do
  let!(:scope) do
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

  let!(:scope_budget) do
    create(
      :scope_budget,
      participatory_process: part_process,
      scope: scope,
      budget_value: 10_000_000,
      max_proposal_budget_value: 1_000_000
    )
  end
end
