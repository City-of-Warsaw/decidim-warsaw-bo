# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module AdminExtended
    describe ContactInfoGroup, type: :model do
      context "contact info group scopes" do
        it "tests scope which returns published records" do
          expect(Decidim::AdminExtended::ContactInfoGroup.published).to eq(Decidim::AdminExtended::ContactInfoGroup.where(published: true))
        end

        it "tests scope which sorts records by weight" do
          expect(Decidim::AdminExtended::ContactInfoGroup.sorted_by_weight).to eq(Decidim::AdminExtended::ContactInfoGroup.order(:weight))
        end
      end

      it "should have many contact info positions" do
        assocation = Decidim::AdminExtended::ContactInfoGroup.reflect_on_association(:contact_info_positions)
        expect(assocation.macro).to eq(:has_many)
      end
    end
  end
end
