# frozen_string_literal: true

require 'rails_helper'
require 'decidim/projects/test/factories'

module Decidim
  module Projects
    describe CoauthorshipsController, type: :controller do
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

      describe 'GET actions' do
        describe 'edit - action' do
          context 'When there is an unlogged user' do
            it 'redirects to sign in a user with flash alert' do
              get :edit, params: { id: project.id }

              expect(response).to redirect_to(decidim.new_user_session_path)
              expect(flash[:alert]).to eq('Zaloguj się i kliknij ponownie w link z maila, by móc potwierdzić współautorstwo projektu')
            end
          end

          context 'When there is no project' do
            it 'redirects to all projects with flash alert' do
              project.id = 1000
              sign_in user

              get :edit, params: { id: project.id }

              expect(response).to redirect_to('/projects')
              expect(flash[:alert]).to eq('Nie znaleziono projektu')
            end
          end

          context 'When coauthorship is false' do
            it 'redirects to new projet with flash alert' do
              sign_in user
              project.coauthorships.first.update_columns(confirmation_status: 'confirmed')

              get :edit, params: { id: project.id }

              expect(flash[:alert]).to eq('Nie znaleziono zaproszenia do współautorstwa, lub zostalo ono anulowane przez autora projektu')
              expect(response).to redirect_to(Decidim::ResourceLocatorPresenter.new(project).path)
            end
          end

          it 'assigns correct coauthorship' do
            sign_in user

            get :edit, params: { id: project.id }
          end
        end
      end

      describe 'POST actions' do
        describe 'update - action' do
          let(:project_wizard_author_step_validatations_params) do
            { first_name: user.first_name,
              last_name: user.last_name,
              gender: user.gender,
              street: user.street,
              street_number: user.street_number,
              zip_code: user.zip_code,
              city: user.city
            }
          end

          let(:permission_action) do
            PermissionAction.new(scope: :public, action: :coauthor, subject: :project)
          end

          it 'checks if permission action matches' do
            expect(permission_action.matches?(:public, :coauthor, :project)).to be true
          end

          context 'When a user does not have permissions' do
            it 'flash error with redirect that is in permissions coauthorship' do
              project.coauthorships.first.update_columns(decidim_author_id: 1000)

              sign_in user

              post :update, params: { id: project.id, coauthorship: project_wizard_author_step_validatations_params.merge(project_id: project.id) }
              expect(flash[:alert]).to eq('Nie masz uprawnień do wykonania tej czynności')
            end
          end

          context 'When there an invalid form' do
            let(:project_wizard_author_step_validatations_params) do
              { first_name: user.first_name,
                last_name: user.last_name,
                gender: nil,
                street: user.street,
                street_number: user.street_number,
                zip_code: user.zip_code,
                city: user.city
              }
            end

            it 'redirects to accepting coauthorship projet with flash alert' do
              sign_in user

              post :update, params: { id: project.id, coauthorship: project_wizard_author_step_validatations_params.merge(project_id: project.id) }

              expect(flash[:alert]).to eq('Nie udało sie potwierdzić współautorstwa')
              expect(subject).to render_template(:edit)
            end
          end

          context 'Permission - OK, Form - valid' do
            xit 'redirects to new project with flash notice' do
              sign_in user

              post :accepting_coauthorship, params: { id: project.id, coauthorship: project_wizard_author_step_validatations_params.merge(project_id: project.id) }
            end
          end
        end
      end
    end
  end
end
