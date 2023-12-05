# frozen_string_literal: true

require 'rails_helper'

module Decidim
  RSpec.describe 'submit project as podkoordynator', type: %i[feature mailer] do
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
        ad_role: :decidim_bo_bie_podkoord
      )
    end

    it 'creates project, redirect to show with flash message' do
      sign_in(user)
      visit url_target

      fill_in 'Nazwa projektu',
              with: "Projekt testowy wprowadzony przez #{user.ad_role}"
      fill_in 'Skrócony opis projektu',
              with: 'Skrócony opis projektu'
      fill_in 'Opis projektu',
              with: 'Opis projektu'
      check('Tak')
      fill_in 'Uzasadnienie realizacji projektu',
              with: 'Uzasadnienie realizacji projektu'
      check('edukacja')
      check('dorośli')
      select('Bielany')
      fill_in 'Lokalizacja projektu - ulica i nr / rejon ulic w Warszawie',
              with: 'Lokalizacja projektu - ulica i nr / rejon ulic w Warszawie'
      fill_in 'Inne istotne informacje dotyczące lokalizacji',
              with: 'Inne istotne informacje dotyczące lokalizacji'
      fill_in 'Wpisz adres, podając pełną nazwę np. ulicy',
              with: 'Dewajtis'
      find('#auto-selected-option-0').click
      fill_in 'Szacunkowy koszt realizacji projektu', with: 1000
      page.attach_file(file_fixture('processes/obowiazkowa_lista_poparcia.pdf')) do
        page.find('input[name="project[add_endorsements][]"]').click
      end
      page.attach_file(file_fixture('processes/dodatkowo_zalaczniki_1.pdf')) do
        page.find('input[name="project[add_files][]"]').click
      end
      page.attach_file(file_fixture('processes/dodatkowo_zgoda_na_wykorzystanie_utworu.pdf')) do
        page.find('input[name="project[add_consents][]"]').click
      end
      page.attach_file(file_fixture('processes/dokument_wewnetrzny_1.pdf')) do
        page.find('input[name="project[add_internal_documents][]"]').click
      end
      check('Wniosek nieczytelny')
      fill_in 'Uwagi osoby wprowadzającej formularz papierowy',
              with: 'Uwagi osoby wprowadzającej formularz papierowy'

      fill_in 'Imię', with: 'Jan'
      fill_in 'Nazwisko', with: 'Testowy'
      choose('Mieszkaniec')
      fill_in 'Telefon kontaktowy', with: '+48 123 456 789'
      fill_in 'Adres e-mail', with: email_author
      fill_in 'Ulica', with: 'Dewajtis'
      fill_in 'Nr domu', with: '3'
      fill_in 'Nr mieszkania', with: '4'
      fill_in 'Kod pocztowy', with: '01-815'
      fill_in 'Miasto', with: 'Warszawa'

      page.check('project[show_author_name]')
      page.check('project[inform_author_about_implementations]')
      page.check('project[email_on_notification]')
      page.check('project[signed_by_author]')

      expect { click_button 'Utwórz' }.to change(::Decidim::Projects::Project, :count).from(0).to(1)
      expect(page).to have_content('Projekt został utworzony.')
      expect(page).to have_current_path(url_expected)

      click_link 'Oddaj projekt do rozpatrzenia'
    end
  end
end
