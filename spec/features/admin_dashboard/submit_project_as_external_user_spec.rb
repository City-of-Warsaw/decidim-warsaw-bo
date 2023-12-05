# frozen_string_literal: true

require 'rails_helper'

module Decidim
  RSpec.describe 'submit project as external user', type: %i[feature mailer] do
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

    let!(:user) do
      create(
        :user,
        :confirmed,
        organization: organization,
        email: 'user+confirmed@localhost',
        admin: false,
        admin_terms_accepted_at: nil
      )
    end

    it 'raises Routing Error during malicious action and attempt to get to admin panel' do
      sign_in(user)
      visit url_target
      expect { visit url_target }.to raise_error(ActionController::RoutingError)
    end
  end
end
