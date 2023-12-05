# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe User do
    let(:user) { create(:user, :confirmed, gender: 'male') }

    context "user is valid" do
      it 'has no gender' do
        user.gender = ''
        expect(user).to be_valid
      end

      # it 'has no birth_year' do
      #   user.birth_year = nil
      #   expect(user).to be_valid
      # end

      # it 'has no district' do
      #   user.district = ''
      #   expect(user).to be_valid
      # end
    end

    context "user has AD role" do
      it '#ad_admin?' do
        user.ad_role = 'decidim_bo_admin'
        expect(user.ad_admin?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_coordinator?' do
        user.ad_role = 'decidim_bo_koord'
        expect(user.ad_coordinator?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_sub_coordinator?' do
        user.ad_role = 'decidim_bo_podkoord'
        expect(user.ad_sub_coordinator?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_verifier?' do
        user.ad_role = 'decidim_bo_weryf'
        expect(user.ad_verifier?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_editor?' do
        user.ad_role = 'decidim_bo_edytor'
        expect(user.ad_editor?).to be true
        expect(user.has_ad_role?).to be true
      end
    end

    context 'user has no AD role' do
      it 'when ad_role not defined' do
        user.ad_role = 'random'
        expect(user.has_ad_role?).to be false
      end

      it 'when ad_role empty' do
        user.ad_role = ' '
        expect(user.has_ad_role?).to be false
      end

      it 'when ad_role nil' do
        user.ad_role = nil
        expect(user.has_ad_role?).to be false
      end
    end

    context 'user has ad_role set with' do
      it '#assign_ad_role!(admin)' do
        expect(user.has_ad_role?).to be false
        expect(user.ad_admin?).to be false
        expect(user.admin).to be false
        user.assign_ad_role!('admin')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.admin).to be true
      end

      it '#assign_ad_role!(coordinator)' do
        user.assign_ad_role!('coordinator')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_coordinator?).to be true
        expect(user.admin).to be false
      end

      it '#assign_ad_role!(sub_coordinator)' do
        user.assign_ad_role!('sub_coordinator')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_sub_coordinator?).to be true
        expect(user.admin).to be false
      end

      it '#assign_ad_role!(verificator)' do
        user.assign_ad_role!('verificator')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_verifier?).to be true
        expect(user.admin).to be false
      end

      it '#assign_ad_role!(editor)' do
        user.assign_ad_role!('editor')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_editor?).to be true
        expect(user.admin).to be false
      end
    end

    context 'user has not ad_role set' do
      it 'with wrong name' do
        expect(user.assign_ad_role!('random')).to be_nil
        user.reload
        expect(user.has_ad_role?).to be false
        expect(user.admin).to be false
      end

      it 'with empty value passed' do
        expect(user.assign_ad_role!(' ')).to be_nil
        user.reload
        expect(user.has_ad_role?).to be false
        expect(user.admin).to be false
      end

      it 'with nil value passed' do
        expect(user.assign_ad_role!(nil)).to be_nil
        user.reload
        expect(user.has_ad_role?).to be false
        expect(user.admin).to be false
      end
    end
  end
end
