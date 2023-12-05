# frozen_string_literal: true

require 'rails_helper'
require 'decidim/admin_extended/test/factories'

module Decidim
  module AdminExtended
    describe Admin::BudgetInfoPositionsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { AdminEngine.routes }

      let(:decidim_admin_extended) { AdminEngine.routes.url_helpers }
      let!(:organization) { create :organization, available_locales: [:pl] }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_bo_cks_admin' }

      let(:budget_info_group) { create(:budget_info_group) }
      let(:budget_info_position) { create(:budget_info_position) }
      let(:budget_info_position_params) { attributes_for(:budget_info_position).merge(budget_info_group_id: budget_info_group) }

      before do
        request.env['decidim.current_organization'] = organization
        sign_in admin
      end

      describe 'GET actions' do
        it 'renders an index' do
          get :index

          expect(subject).to render_template(:index)
        end

        context 'get new' do
          it 'renders a new' do
            get :new

            expect(subject).to render_template(:new)
          end

          it 'redirects on new' do
            get :new

            expect(response).to have_http_status(:success)
          end
        end

        context 'get edit' do
          it 'renders correct template' do
            get :edit, params: { id: budget_info_position.id }
            expect(subject).to render_template(:edit)
          end

          it 'gets correct response' do
            get :edit, params: { id: budget_info_position.id }

            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'POST create' do
        it 'creates budget info position when params are valid' do
          post :create, params: { budget_info_position: budget_info_position_params }

          expect { budget_info_position }.to change( Decidim::AdminExtended::BudgetInfoPosition, :count).by(1)
          expect(flash[:notice]).to eq(I18n.t('budget_info_positions.create.success', scope: 'decidim.admin_extended.admin'))
          expect(subject).to redirect_to(decidim_admin_extended.budget_info_positions_path)
        end

        context 'when params are invalid' do
          it 'does not create budget info position' do
            params = budget_info_position_params.merge(description: nil)
            expect do
              post :create, params: { budget_info_position: params }
            end.not_to change(Decidim::AdminExtended::BudgetInfoPosition, :count)

            expect(flash[:alert]).to eq(I18n.t('budget_info_positions.create.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:new)
          end
        end
      end

      describe 'PATCH update' do
        it 'updates budget info position when params are valid' do
          patch :update, params: { id: budget_info_position.id, budget_info_position: budget_info_position_params }

          expect(flash[:notice]).to eq(I18n.t('budget_info_positions.update.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.budget_info_positions_path)
        end

        context 'when params are invalid' do
          it 'does not update budget info position' do
            params = budget_info_position_params.merge(name: nil)
            patch :update, params: { id: budget_info_position.id, budget_info_position: params }

            expect(flash[:alert]).to eq(I18n.t('budget_info_positions.update.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:edit)
          end
        end
      end

      describe 'DELETE destroy' do
        it 'destroys budget info position' do
          delete :destroy, params: { id: budget_info_position }

          # expect { budget_info_position }.to change( Decidim::AdminExtended::BudgetInfoPosition, :count).by(-1)
          expect { budget_info_position.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(flash[:notice]).to eq(I18n.t('budget_info_positions.destroy.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.budget_info_positions_path)
        end
      end
    end
  end
end
