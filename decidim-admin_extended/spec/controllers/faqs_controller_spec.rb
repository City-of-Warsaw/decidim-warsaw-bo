# frozen_string_literal: true

require 'rails_helper'
require 'decidim/admin_extended/test/factories'

module Decidim
  module AdminExtended
    describe Admin::FaqsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::AdminExtended::AdminEngine.routes }

      let(:decidim_admin_extended) { Decidim::AdminExtended::AdminEngine.routes.url_helpers }
      let(:organization) { create(:organization) }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_bo_cks_admin' }

      let(:faq_group) { create(:faq_group) }
      let(:faq) { create(:faq) }
      let(:faq_params) { attributes_for(:faq).merge(faq_group_id: faq_group.id) }

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
            get :edit, params: { id: faq.id }

            expect(subject).to render_template(:edit)
          end

          it 'gets correct response' do
            get :edit, params: { id: faq.id }

            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'POST create' do
        it 'creates faq when params are valid' do
          post :create, params: { faq: faq_params }

          expect { faq }.to change(Decidim::AdminExtended::Faq, :count).by(1)
          expect(flash[:notice]).to eq(I18n.t('faqs.create.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.faqs_path)
        end

        context 'when params are invalid' do
          it 'does not create faq' do
            params = faq_params.merge(weight: nil)
            expect do
              post :create, params: { faq: params }
            end.not_to change(Decidim::AdminExtended::FaqGroup, :count)

            expect(flash[:alert]).to eq(I18n.t('faqs.create.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:new)
          end
        end
      end

      describe 'PATCH update' do
        it 'updates faq when params are valid' do
          patch :update, params: { id: faq.id, faq: faq_params }

          expect(flash[:notice]).to eq(I18n.t('faqs.update.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.faqs_path)
        end

        context 'when params are invalid' do
          it 'does not update faq' do
            params = faq_params.merge(faq_group_id: nil)
            patch :update, params: { id: faq.id, faq: params }

            expect(response).to have_http_status(:success)
            expect(flash[:alert]).to eq(I18n.t('faqs.update.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:edit)
          end
        end
      end

      describe 'DELETE destroy' do
        it 'destroys budget info position' do
          delete :destroy, params: { id: faq }

          # expect { faq }.to change(Decidim::AdminExtended::Faq, :count).by(-1)
          expect { faq.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(flash[:notice]).to eq(I18n.t('faqs.destroy.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.faqs_path)
        end
      end
    end
  end
end
