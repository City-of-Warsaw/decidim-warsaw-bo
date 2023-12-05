# frozen_string_literal: true

require 'rails_helper'
require 'decidim/projects/test/factories'

module Decidim
  module Projects
    describe MessagesController, type: :controller do
      include Rails.application.routes.mounted_helpers

      include_context 'with organization and process and steps'
      include_context 'with scope types'
      include_context 'with content block'
      include_context 'with projects component'
      include_context 'with scope and budget for public'
      include_context 'with recipient and area'

      routes { Decidim::Projects::Engine.routes }

      let(:decidim_projects) { Decidim::Projects::Engine.routes.url_helpers }

      let!(:department) { create(:department) }

      let(:user) do
        create(
          :user,
          :confirmed,
          organization: organization,
          first_name: 'Jan',
          last_name: 'Testowy',
          gender: 'Mieszkaniec',
          phone_number: '+48 123 456 789',
          street: 'Wiejska',
          street_number: '2',
          flat_number: '2',
          zip_code: '00-001',
          city: 'Warszawa',
          admin: false,
          admin_terms_accepted_at: nil
        )
      end

      let(:couauthor_email) { 'coauthor@email' }

      let(:project) do
        project = Decidim::Projects::Project.new(
          title: 'title',
          body: 'body',
          state: 'published',
          reference: 'BO-PROJ-2023-10-26192',
          published_at: Time.current,
          justification_info: 'justification_info',
          localization_info: 'localization_info',
          budget_value: scope_budget.max_proposal_budget_value,
          esog_number: 1,
          short_description: 'short_description',
          localization_additional_info: 'localization_additional_info',
          universal_design: true,
          coauthor_email_one: couauthor_email,
          edition_year: part_process.edition_year,
          verification_status: 'waiting',
          decidim_scope_id: scope.id,
          decidim_component_id: projects_component.id,
          current_department_id: department.id,
          locations:
            { '1698147467327' =>
             { 'lat' => 52.23531676752928,
               'lng' => 21.061820983886722,
               'address' =>
                { 'city' => 'Warsaw',
                  'road' => 'Holenderska',
                  'state' => 'Masovian Voivodeship',
                  'suburb' => 'Praga-Południe',
                  'country' => 'Poland',
                  'quarter' => 'Saska Kępa',
                  'postcode' => '03-925',
                  'country_code' => 'pl',
                  'house_number' => '3',
                  'neighbourhood' => 'Osiedle Międzynarodowa' },
               'display_name' => 'Holenderska 3, 03-925 Warsaw' } },
          recipient_names: recipient.id,
          category_names: area.id
        )

        ProjectAuthorsManager.new(project).add_author(user)
        project.save!

        project.coauthorships
               .first
               .update_columns(
                 decidim_author_id: user.id,
                 decidim_author_type: 'Decidim::UserBaseEntity',
                 coauthorable_id: project.id,
                 decidim_author_type: 'Decidim::UserBaseEntity',
                 coauthorship_acceptance_date: 1.hour.from_now,
                 confirmation_status: 'waiting',
                 coauthor: true
               )

        project
      end

      before do
        request.env['decidim.current_organization'] = organization
        request.env['decidim.current_participatory_space'] = part_process
        request.env['decidim.current_component'] = projects_component
      end


      describe 'POST actions' do
        describe 'send_private_message - action' do
          context 'When there is no project' do
            it 'redirects to all projects with flash alert' do
              project.id = 1000

              sign_in user

              post :send_private_message, params: { id: project.id }

              expect(response).to redirect_to('/projects')
              expect(flash[:alert]).to eq('Nie znaleziono projektu')
            end
          end

          context 'When there is an invalid private message form' do
            let(:private_message_params) { { body: '', email: user.email } }

            it 'shows a flash alert' do
              sign_in user

              post :send_private_message, params: { id: project.id, private_message: private_message_params.merge(project_id: project.id) }

              expect(flash[:alert]).to eq('Nie udało się wysłać wiadomosci do autora projektu')
              expect(response).to redirect_to(Decidim::ResourceLocatorPresenter.new(project).path)
            end
          end

          context 'Form - valid' do
            let(:mail_template_new_private_message) do
              Decidim::AdminExtended::MailTemplate.create(
                {
                  name: 'Powiadomienie o wiadomości prywatnej dla użytkowników',
                  system_name: 'new_private_message',
                  body: "<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
                        <p>Jeden z użytkowników budżetu obywatelskiego w&nbsp;Warszawie chciał się z Tobą skontaktować.</p>
                        <p>Poniżej znajduje się jego adres e-mail, na który możesz odpisać, oraz treść wiadomości:</p>
                        <p>%{sender_email}</p>
                        <p>%{private_message_body}</p>
                        <p>Jeśli treść jest nieodpowiednia, zgłoś ją nam.</p>
                        <p>Z poważaniem, <br>Urząd m.st. Warszawy</p>",
                  subject: 'Budżet obywatelski - Prywatna wiadomość'
                }
              )
            end

            let(:private_message_params) { { body: 'body', email: user.email } }

            before do
              mail_template_new_private_message
            end

            it 'sends a private message to projects author with flash notice' do
              sign_in user

              expect {
                perform_enqueued_jobs do
                  post :send_private_message, params: { id: project.id, private_message: private_message_params.merge(project_id: project.id) }
                end
              }.to change { ActionMailer::Base.deliveries.size }.by(1)

              expect(flash[:notice]).to eq('Wysłano wiadomość prywatną do autora projektu')
              expect(response).to redirect_to(Decidim::ResourceLocatorPresenter.new(project).path)
            end
          end
        end
      end
    end
  end
end
