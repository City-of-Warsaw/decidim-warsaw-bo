# frozen_string_literal: true

require 'rails_helper'

module Decidim
  RSpec.describe 'submit project as unregistered user', type: %i[feature mailer] do
    include_context 'with organization and process and steps'
    include_context 'with scope types'
    include_context 'with content block'
    include_context 'with projects component'
    include_context 'with scopes and department for admin'
    include_context 'with recipient and area'

    let(:email_author) { "jan_testowy+#{user.ad_role}@localhost" }
    let(:url_target) do
      "/admin/participatory_processes/#{part_process.slug}/components/#{projects_component.id}/manage/projects/new"
    end

    let(:url_expected) do
      <<~HEREURL.tr("\n", '')
        /admin/participatory_processes/#{part_process.slug}/components/
        #{projects_component.id}/manage/projects/#{Decidim::Projects::Project.first.id}
      HEREURL
    end

    before do
      travel_to(Time.zone.parse('2023-01-12T00:01:00.000+02:00'))
    end

    it 'redirects to sign in page - as an unregistered user' do
      visit url_target

      expect(page).to have_content('Zaloguj się')
      expect(page).to have_current_path('/users/sign_in')
    end
  end
end
