# frozen_string_literal: true

RSpec.shared_context 'with recipient and area' do
  let!(:recipient) { create(:recipient, name: 'dorośli') }
  let!(:area) { create(:area, organization: organization, name: { "pl": 'edukacja' }) }
end
