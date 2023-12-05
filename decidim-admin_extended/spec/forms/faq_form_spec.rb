# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe FaqForm do
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
        let(:faq_group) { create(:faq_group) }
        let(:attributes) { attributes_for(:faq, faq_group_id: faq_group.id) }

        context "when form is correct" do
          it { expect(subject).to be_valid }
          it { expect(subject.errors.messages).to be_empty }
        end

        context "when title is empty" do
          let(:attributes) { super().merge(title: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:title]).to include('nie może być puste') }
        end

        context "when content is empty" do
          let(:attributes) { super().merge(content: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:content]).to include('nie może być puste') }
        end

        context "when published is not a boolean" do
          let(:attributes) { super().merge(published: "invalid") }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:published]).to include('nie znajduje się na liście dopuszczalnych wartości') }
        end

        context "when weight is empty" do
          let(:attributes) { super().merge(weight: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:weight]).to include('nie może być puste') }
        end

        context "when weight is empty" do
          let(:attributes) { super().merge(faq_group_id: nil) }
          it { expect(subject).not_to be_valid }
          it { expect(subject.errors[:faq_group_id]).to include('nie może być puste') }
        end

        context "checks assignment to non-existent Faq Group" do
          let(:non_existing_faq_group_id) { 2000 }

          it "should not exist" do
            expect(Decidim::AdminExtended::FaqGroup.find_by(id: non_existing_faq_group_id)).to be_nil
          end
        end
      end
    end
  end
end
