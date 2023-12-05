# frozen_string_literal: true

require "rails_helper"

describe Decidim::ParticipatoryProcesses::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: organization }
  let(:organization) { create :organization }
  let(:process) { create :participatory_process, organization: organization }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:process_admin) { create :process_admin, participatory_process: process }
  let(:process_collaborator) { create :process_collaborator, participatory_process: process }
  let(:process_moderator) { create :process_moderator, participatory_process: process }
  let(:process_valuator) { create :process_valuator, participatory_process: process }

  context "when creating a process" do
    let(:action) do
      { scope: :admin, action: :create, subject: :process }
    end
    let(:context) { { process: process } }

    context "when the user is an admin" do
      # control test
      let(:user) { create :user, :admin }
      it { is_expected.to eq false }
    end

    context "when the user has no role" do
      # control test
      let(:user) { create :user }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - admin" do
      let(:user) { create :user, ad_role: 'admin' }
      it { is_expected.to eq true }
    end

    context "when the user has ad_role - coordinator" do
      let(:user) { create :user, ad_role: 'coordinator' }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - sub_coordinator" do
      let(:user) { create :user, ad_role: 'sub_coordinator' }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - verifiactor" do
      let(:user) { create :user, ad_role: 'verifiactor' }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - editor" do
      let(:user) { create :user, ad_role: 'editor' }
      it { is_expected.to eq false }
    end
  end

  context "when publishing a process" do
    let(:action) do
      { scope: :admin, action: :publish, subject: :process }
    end
    let(:context) { { process: process } }

    context "when the user is an admin" do
      let(:user) { create :user, :admin }
      it { is_expected.to eq false }
    end

    context "when the user is an process_admin" do
      let(:user) { process_admin }
      it { is_expected.to eq false }
    end

    context "when the user is an process_collaborator" do
      let(:user) { process_collaborator }
      it { is_expected.to eq false }
    end

    context "when the user is an process_moderator" do
      let(:user) { process_moderator }
      it { is_expected.to eq false }
    end

    context "when the user is an process_valuator" do
      let(:user) { process_valuator }
      it { is_expected.to eq false }
    end

    context "when the user has no role" do
      let(:user) { create :user }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - admin" do
      let(:user) { create :user, :admin_terms_accepted, ad_role: 'admin' }
      it { is_expected.to eq true }
    end

    context "when the user has ad_role - coordinator" do
      let(:user) { create :user, :admin_terms_accepted, ad_role: 'coordinator' }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - sub_coordinator" do
      let(:user) { create :user, :admin_terms_accepted, ad_role: 'sub_coordinator' }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - verifiactor" do
      let(:user) { create :user, :admin_terms_accepted, ad_role: 'verifiactor' }
      it { is_expected.to eq false }
    end

    context "when the user has ad_role - editor" do
      let(:user) { create :user, :admin_terms_accepted, ad_role: 'editor' }
      it { is_expected.to eq false }
    end
  end
end
