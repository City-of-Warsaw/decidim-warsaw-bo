# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module AdminExtended
    describe Faq, type: :model do
      context "Faq scopes" do
        it "filter only published records" do
          expect(Decidim::AdminExtended::Faq.published).to eq(Decidim::AdminExtended::Faq.where(published: true))
        end

        it "checks sorting records with published" do
          expect(Decidim::AdminExtended::Faq.sorted_by_weight).to eq(Decidim::AdminExtended::Faq.order(:weight))
        end
      end

      it "tests association" do
        association = Decidim::AdminExtended::Faq.reflect_on_association(:faq_group)

        expect(association.macro).to eq(:belongs_to)
      end
    end
  end
end
