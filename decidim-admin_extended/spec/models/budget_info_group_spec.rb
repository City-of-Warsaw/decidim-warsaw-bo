# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module AdminExtended
    describe BudgetInfoGroup, type: :model do
      context "budget info group scopes" do
        it "is scope which returns published records" do
          expect(Decidim::AdminExtended::BudgetInfoGroup.published).to eq(Decidim::AdminExtended::BudgetInfoGroup.where(published: true))
        end

        it "is scope which sorts records by weight" do
          expect(Decidim::AdminExtended::BudgetInfoGroup.sorted_by_weight).to eq(Decidim::AdminExtended::BudgetInfoGroup.order(:weight))
        end
      end

      it "tests association" do
        association = Decidim::AdminExtended::BudgetInfoGroup.reflect_on_association(:budget_info_positions)

        expect(association.macro).to eq(:has_many)
      end
    end
  end
end
