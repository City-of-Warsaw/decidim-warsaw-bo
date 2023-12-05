# frozen_string_literal: true

require 'rails_helper'
require 'decidim/admin_extended/test/factories'

module Decidim
  module AdminExtended
    describe Admin::ContactInfoGroupsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::AdminExtended::AdminEngine.routes }

      let(:decidim_admin_extended) { Decidim::AdminExtended::AdminEngine.routes.url_helpers }
      let!(:organization) { create :organization, available_locales: [:pl] }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_bo_cks_admin' }

      let(:contact_info_group) { create(:contact_info_group) }
      let(:contact_info_group_params) { attributes_for(:contact_info_group) }

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
            get :edit, params: { id: contact_info_group.id }

            expect(subject).to render_template(:edit)
          end

          it 'gets correct response' do
            get :edit, params: { id: contact_info_group.id }

            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'POST create' do
        it 'creates contact info group when params are valid' do
          post :create, params: { contact_info_group: contact_info_group_params }

          expect { contact_info_group }.to change(Decidim::AdminExtended::ContactInfoGroup, :count).by(1)
          expect(flash[:notice]).to eq(I18n.t('contact_info_groups.create.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.contact_info_positions_path)
        end

        context 'when params are invalid' do
          it 'does not create contact info group' do
            params = contact_info_group_params.merge(name: nil)
            expect do
              post :create, params: { contact_info_group: params }
            end.not_to change(Decidim::AdminExtended::ContactInfoGroup, :count)
            expect(flash[:alert]).to eq(I18n.t('contact_info_groups.create.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:new)
          end
        end
      end

      describe 'PATCH update' do
        it 'updates contact info group when params are valid' do
          patch :update, params: { id: contact_info_group.id, contact_info_group: contact_info_group_params }

          expect(flash[:notice]).to eq(I18n.t('contact_info_groups.update.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.contact_info_positions_path)
        end

        context 'when params are invalid' do
          it 'does not update contact info group' do
            params = contact_info_group_params.merge(published: nil)
            patch :update, params: { id: contact_info_group.id, contact_info_group: params }

            expect(flash[:alert]).to eq(I18n.t('contact_info_groups.update.errors', scope: 'decidim.admin_extended.admin'))
            expect(subject).to render_template(:edit)
          end
        end
      end

      describe 'DELETE destroy' do
        it 'destroys contact info group' do
          delete :destroy, params: { id: contact_info_group }

          # expect { contact_info_group }.to change(Decidim::AdminExtended::ContactInfoGroup, :count).by(-1)
          expect { contact_info_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(flash[:notice]).to eq(I18n.t('contact_info_groups.destroy.success', scope: 'decidim.admin_extended.admin'))
          expect(response).to redirect_to(decidim_admin_extended.contact_info_positions_path)
        end
      end
    end
  end
end
