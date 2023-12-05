# frozen_string_literal: true

require 'rails_helper'
require 'decidim/admin_extended/test/factories'

module Decidim
  module AdminExtended
    describe Admin::FaqGroupsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::AdminExtended::AdminEngine.routes }

      let(:decidim_admin_extended) { Decidim::AdminExtended::AdminEngine.routes.url_helpers }
      let!(:organization) { create :organization, available_locales: [:pl] }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_bo_cks_admin' }

      let(:faq_group) { create(:faq_group) }
      let(:faq_group_params) { attributes_for(:faq_group) }

      before do
        request.env['decidim.current_organization'] = organization
        sign_in admin
      end

      describe 'GET actions' do
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
            get :edit, params: { id: faq_group.id }

            expect(subject).to render_template(:edit)
          end

          it 'gets correct response' do
            get :edit, params: { id: faq_group.id }

            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'POST create' do
        it 'creates faq group when params are valid' do
          post :create, params: { faq_group: faq_group_params }

          expect { faq_group }.to change(Decidim::AdminExtended::FaqGroup, :count).by(1)
          expect(flash[:notice]).to eq(I18n.t('faq_groups.create.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.faqs_path)
        end

        context 'when params are invalid' do
          it 'does not create faq group' do
            params = faq_group_params.merge(title: nil)
            expect do
              post :create, params: { budget_info_group: params }
            end.not_to change(Decidim::AdminExtended::FaqGroup, :count)

            expect(flash[:alert]).to eq(I18n.t('faq_groups.create.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:new)
          end
        end
      end

      describe 'PATCH update' do
        it 'updates faq group when params are valid' do
          patch :update, params: { id: faq_group.id, faq_group: faq_group_params }

          expect(flash[:notice]).to eq(I18n.t('faq_groups.update.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.faqs_path)
        end

        it 'does not update faq group when params are invalid' do
          params = faq_group_params.merge(weight: nil)
          patch :update, params: { id: faq_group.id, faq_group: params }

          expect(flash[:alert]).to eq(I18n.t('faq_groups.update.errors', scope: 'decidim.admin_extended.admin'))
          expect(subject).to render_template(:edit)
        end
      end

      describe 'DELETE destroy' do
        it 'destroys faq group' do
          delete :destroy, params: { id: faq_group }

          # expect { faq_group }.to change( Decidim::AdminExtended::FaqGroup, :count).by(-1)
          expect { faq_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(flash[:notice]).to eq(I18n.t('faq_groups.destroy.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.faqs_path)
        end
      end
    end
  end
end
