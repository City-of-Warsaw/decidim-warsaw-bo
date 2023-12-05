# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe BudgetInfoPositionForm do
        include Rack::Test::Methods

        # temporary solution for testing form
        subject do
          form = described_class.from_params(
            attributes
          )
          form.valid?
          form
        end

        # decidim solution - decidim specs form (static_pages), DO not have specs for expecting errors content
        # subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let!(:organization) { create :organization, available_locales: [:pl] }
        let(:budget_info_group) { create(:budget_info_group) }
        let(:attributes) { attributes_for(:budget_info_position, budget_info_group_id: budget_info_group.id) }

        context "when form is correct" do
          it { expect(subject).to be_valid }
          it { expect(subject.errors.messages).to be_empty }
        end

        context "when name is empty" do
          let(:attributes) { super().merge(name: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:name]).to include('nie może być puste') }
        end

        context "when description is empty" do
          let(:attributes) { super().merge(description: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:description]).to include('nie może być puste') }
        end

        context "when published is empty" do
          let(:attributes) { super().merge(published: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:published]).to include('nie znajduje się na liście dopuszczalnych wartości') }
        end

        context "when weight is empty" do
          let(:attributes) { super().merge(weight: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:weight]).to include('nie może być puste') }
        end

        context "when budget_info_group_id is empty" do
          let(:attributes) { super().merge(budget_info_group_id: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:budget_info_group_id]).to include('nie może być puste') }
        end
      end
    end
  end
end
