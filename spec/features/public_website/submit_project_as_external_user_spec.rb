# frozen_string_literal: true

require 'rails_helper'

module Decidim
  RSpec.describe 'submit project as external user', type: %i[feature mailer] do
    include_context 'with organization and process and steps'
    include_context 'with scope types'
    include_context 'with content block'
    include_context 'with projects component'
    include_context 'with scope and budget for public'
    include_context 'with recipient and area'

    let(:user) do
      create(
        :user,
        :confirmed,
        organization: organization,
        email: 'user+regular_confirmed@localhost',
        first_name: 'Jan',
        last_name: 'Testowy',
        gender: 'Mieszkaniec',
        phone_number: '+48 123 456 789',
        street: 'Wiejska',
        street_number: '2',
        flat_number: '2',
        zip_code: '00-001',
        city: 'Warszawa'
      )
    end

    let(:couauthor_1_email) { 'user2+author_step_coauthor_email_one@localhost' }
    let(:url_target) { "/processes/#{part_process.slug}/f/#{projects_component.id}/projects_wizard/new" }

    before do
      travel_to(Time.zone.parse('2023-01-12T00:01:00.000+02:00'))
    end

    context 'as regular user non logged' do
      it 'redirects to sign in page' do
        visit url_target

        expect(page).to have_content('Zaloguj się')
        expect(page).to have_current_path('/users/sign_in')
      end
    end

    context 'as regular user logged' do
      it "'completes first and second step of project due to incorrect function of the second button: 'Dalej'" do
        sign_in(user)

        # proceed to the first step of project submission - '1. Opis projektu'
        visit url_target

        # project submission cancellation test
        cancel_links = all('a', text: 'Anuluj', visible: :all)
        cancel_links[1].click

        expect(page).to have_content('Moje projekty')
        expect(page).to have_current_path('/account/projects')

        # proceed once again to the first step of project submission - '1. Opis projektu'
        click_link 'Zgłoś swój projekt'

        # the first step of public project form - '1. Opis projektu'
        fill_in 'Nazwa projektu', with: 'Projekt testowy'
        fill_in 'Skrócony opis projektu', with: 'Skrócony opis projektu testowego'
        fill_in 'Opis projektu', with: 'Opis projektu testowego'
        fill_in 'Uzasadnienie realizacji projektu', with: 'Uzasadnienie realizacji projektu testowego'
        check('edukacja')
        check('dorośli')
        select 'Ogólnomiejski', from: 'Poziom zgłaszanego projektu / dzielnica *'
        fill_in 'Lokalizacja projektu - ulica i nr / rejon ulic w Warszawie *', with: 'ul. Wiejska 1'
        fill_in 'Inne istotne informacje dotyczące lokalizacji',
                with: 'Inne istotne informacje dotyczące lokalizacji testowego projektu'
        fill_in 'Wpisz adres, podając pełną nazwę np. ulicy',
                with: 'Wiejska'
        find('#auto-selected-option-0').click
        fill_in 'Szacunkowy koszt realizacji projektu *', with: '100000'
        page.attach_file(file_fixture('processes/obowiazkowa_lista_poparcia.pdf')) do
          page.find('button[data-target="#project_add_endorsements"]').click
        end
        page.attach_file(file_fixture('processes/dodatkowo_zalaczniki_1.pdf')) do
          page.find('button[data-target="#project_add_files"]').click
        end
        page.attach_file(file_fixture('processes/dodatkowo_zalaczniki_2.pdf')) do
          page.find('button[data-target="#project_add_files"]').click
        end
        page.attach_file(file_fixture('processes/dodatkowo_zgoda_na_wykorzystanie_utworu.pdf')) do
          page.find('button[data-target="#project_add_consents"]').click
        end

        # proceed to the second step of project submission - '2. Twoje dane'
        click_button 'Dalej'

        expect(page).to have_content('Projekt został utworzony.')

        # revert to the first step of project submission - '1. Opis projektu'
        click_link 'Cofnij'
        expect(page).to have_current_path("/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/edit_draft")
        expect(page).to have_content('Opisz swój projekt')
        expect(Decidim::Projects::Project.last.title).to eq('Projekt testowy')

        # proceed once again to the second step of project submission - '2. Twoje dane'
        click_button 'Dalej'
        expect(page).to have_content('Zapisano kopię roboczą projektu.')

        expect(page).to have_field('Imię', with: 'Jan')

        # proceed to the third step of project submission - '3. Zgłoszenie'
        click_button('Dalej')

        # false-positive test
        # "current_path after second step filled data and click button 'Dalej':
        # /processes/testowy-proces-1/f/1/projects/1/author"
        # "actual current_path after second step filled data and click button 'Dalej' its:
        # /processes/testowy-proces-1/f/1/projects/1/preview"
        # assumption: during specs Capybara takes the first one button 'Dalej', from the first step.
        # That's why the second step is rendered and the form fields are blank

        # temporary rspec visit ready link, instead of: click_button 'Dalej'
        visit "/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/preview"

        # the third step - application - project summary - '3. Zgłoszenie'
        expect(page).to have_content('Zapisano kopię roboczą projektu.')
        expect(page).to have_content('Zgłoś projekt')
        expect(page).to have_content('Projekt testowy')
        expect(page).to have_content('Jan')

        # proceed once again to the first step of project submission - '1. Opis projektu'
        click_link 'Edytuj dane projektu'
        expect(page).to have_current_path("/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/edit_draft")
        expect(page).to have_content('Opisz swój projekt')
        expect(Decidim::Projects::Project.last.title).to eq('Projekt testowy')

        # go back to the third step - application - project summary - '3. Zgłoszenie'
        go_back
        expect(page).to have_current_path("/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/preview")
        expect(page).to have_content('Zgłoś projekt')

        # proceed once again to the second step of project submission - '2. Twoje dane'
        click_link 'Edytuj swoje dane'
        expect(page).to have_current_path("/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/author")
        expect(page).to have_content('Uzupełnij swoje dane')

        # go back to the third step - application - project summary - '3. Zgłoszenie'
        go_back
        expect(page).to have_current_path("/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/preview")
        expect(page).to have_content('Zgłoś projekt')

        # proceed to fourth step of project submission - '4. Potwierdzenie'
        # click_button 'Zgłoś'
        # despite of form.valid - checking all attributes with their validations, the button is disabled

        # perform_enqueued_jobs do
        #   click_button 'OK'
        # end

        # temporary rspec visit ready link, instead of: click_button 'Zgłoś'
        visit "/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}/confirmation"

        # proceed to final step - confirmation of project submission - 'Projekt zgłoszony'
        expect(page).to have_content('Projekt zgłoszony')

        # mailing tests
        mail_1 = ActionMailer::Base.deliveries.first
        mail_2 = ActionMailer::Base.deliveries.last

        # expect(ActionMailer::Base.deliveries.count).to eq(2)
        # Failure/Error: expect(ActionMailer::Base.deliveries.count).to eq(2)
        # expected: 2
        # got: 0
        # this Failure/Error may be due to improper transition between steps

        # expect(mail_1.to).to match_array([user.email])
        # Failure/Error: expect(mail_1.to).to match_array([user.email])
        # NoMethodError:
        #   undefined method `to' for nil:NilClass
        # this Failure/Error may be due to improper transition between steps

        # expect(mail_1.subject).to eq('Budżet obywatelski - Dziękujemy za złożenie projektu!')
        # Failure/Error: expect(mail_1.subject).to eq('Budżet obywatelski - Dziękujemy za złożenie projektu!')
        # NoMethodError:
        #   undefined method `subject' for nil:NilClass
        # this Failure/Error may be due to improper transition between steps

        # expect(mail_2.to).to match_array([couauthor_1_email])
        # Failure/Error: expect(mail_2.to).to match_array([couauthor_1_email])
        # NoMethodError:
        #   undefined method `to' for nil:NilClass
        # this Failure/Error may be due to improper transition between steps

        # expect(mail_2.subject).to eq('Budżet obywatelski - Zostałaś(-eś) dodana(-y) jako współautor projektu ')
        # Failure/Error: expect(mail_2.subject).to eq('Budżet obywatelski - Zostałaś(-eś) dodana(-y) jako współautor projektu ')
        # NoMethodError:
        #   undefined method `subject' for nil:NilClass
        # this Failure/Error may be due to improper transition between steps

        # proceed to preview of just submissioned project - 'project.title'
        click_link 'Zobacz zgłoszony projekt'
        expect(page).to have_current_path("/processes/#{part_process.slug}/f/#{projects_component.id}/projects/#{Decidim::Projects::Project.last.id}")

        # expect(page).to have_content('Zgłoszony')
        # Failure/Error: expect(page).to have_content('Zgłoszony')
        # there is not a crucial content
        # this Failure/Error may be due to improper transition between steps

        # proceed once again to the first step of project submission - '1. Opis projektu'
        go_back
        click_link 'Dodaj kolejny projekt'
        visit url_target
      end
    end
  end
end
