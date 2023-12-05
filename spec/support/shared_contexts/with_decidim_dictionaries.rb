# frozen_string_literal: true

RSpec.shared_context 'with decidim dictionaries' do
  # In order to to get array of codes from district_list, just call:
  # district_list.call.map { |i| i[:code] }
  let(:district_list) do
    proc do
      Class.new do
        include DecidimDictionaries
      end.new.district_list
    end
  end
end
