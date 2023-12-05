# frozen_string_literal: true

RSpec.shared_context 'with content block' do
  let!(:content_block) do
    create(
      :content_block,
      organization: organization,
      manifest_name: :hero,
      scope_name: :homepage,
      settings: {
        welcome_text: {
          pl: 'Złóż projekt'
        },
        welcome_text_en: nil,
        welcome_text_pl: 'Złóż projekt'
      }
    )
  end
end
