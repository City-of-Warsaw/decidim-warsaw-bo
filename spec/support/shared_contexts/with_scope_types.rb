# frozen_string_literal: true

RSpec.shared_context 'with scope types' do
  let(:scope_type_dzielnica) do
    create(
      :scope_type,
      name: { "pl": 'Dzielnicowy' },
      plural: { "pl": 'Dzielnicowy' }
    )
  end

  let(:scope_type_ogolnomiejski) do
    create(
      :scope_type,
      name: { "pl": 'Ogólnomiejski' },
      plural: {  "pl": 'Ogólnomiejskie' }
    )
  end
end
