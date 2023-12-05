# frozen_string_literal: true

require 'rails_helper'

module Decidim
  RSpec.describe 'submit project link', type: :feature do
    include_context 'with organization and process and steps'
    include_context 'with content block'
    include_context 'with projects component'

    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:expected_link_name) { 'ZGŁOŚ PROJEKT' }
    let!(:url_target) { "/processes/#{part_process.slug}/f/#{projects_component.id}/projects_wizard/new" }

    context 'Submit a project link visibility by participatory_process_step' do
      context 'before start_date' do
        before do
          travel_to(Time.zone.parse('2022-12-11T23:59:00.000+02:00'))
        end

        context 'as regular user non logged' do
          it 'is not visible' do
            visit '/'

            expect(page).not_to have_link(expected_link_name, href: url_target)
          end
        end

        context 'as regular user logged' do
          it 'is not visible' do
            sign_in(user)

            visit '/'

            expect(page).not_to have_link(expected_link_name, href: url_target)
          end
        end
      end

      context 'between start_date and end_date' do
        before do
          travel_to(Time.zone.parse('2023-01-12T00:01:00.000+02:00'))
        end

        context 'as regular user non logged' do
          it 'is visible' do
            visit '/'

            expect(page).to have_link(expected_link_name, href: url_target)
          end
        end

        context 'as regular user logged' do
          it 'is visible' do
            sign_in(user)

            visit '/'

            expect(page).to have_link(expected_link_name, href: url_target)
          end
        end
      end

      context 'after end_date' do
        before do
          travel_to(Time.zone.parse('2023-01-18T00:01:00.000+02:00'))
        end

        context 'as regular user non logged' do
          it 'is not visible' do
            visit '/'

            expect(page).not_to have_link(expected_link_name, href: url_target)
          end
        end

        context 'as regular user logged' do
          it 'is not visible' do
            sign_in(user)

            visit '/'

            expect(page).not_to have_link(expected_link_name, href: url_target)
          end
        end
      end
    end
  end
end
