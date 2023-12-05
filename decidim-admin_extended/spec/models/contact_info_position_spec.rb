# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module AdminExtended
    describe ContactInfoPosition, type: :model do
      context "contact info position scopes" do
        it "tests scope which returns published records" do
          expect(ContactInfoPosition.published).to eq(Decidim::AdminExtended::ContactInfoPosition.where(published: true))
        end

        it "tests scope which sorts records by weight" do
          expect(ContactInfoPosition.sorted_by_weight).to eq(Decidim::AdminExtended::ContactInfoPosition.order(:weight))
        end
      end

      it "tests association" do
        association = Decidim::AdminExtended::ContactInfoPosition.reflect_on_association(:contact_info_group)
        expect(association.macro).to eq(:belongs_to)
      end
    end
  end
end
