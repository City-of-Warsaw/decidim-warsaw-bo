# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module AdminExtended
    describe FaqGroup, type: :model do
      context "scopes" do
        it { expect(Decidim::AdminExtended::FaqGroup.published).to eq(Decidim::AdminExtended::FaqGroup.where(published: true)) }
        it { expect(Decidim::AdminExtended::FaqGroup.sorted_by_weight).to eq(Decidim::AdminExtended::FaqGroup.order(:weight)) }
      end

      it "tests association" do
        association = Decidim::AdminExtended::FaqGroup.reflect_on_association(:faqs)

        expect(association.macro).to eq(:has_many)
      end
    end
  end
end
