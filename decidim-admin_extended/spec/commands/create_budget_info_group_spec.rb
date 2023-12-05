# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe CreateBudgetInfoGroup do
        let(:command) { described_class.new(form) }
        let(:budget_info_group) { create(:budget_info_group) }
        let(:form) { Admin::BudgetInfoGroupForm.new }

        it "is not valid" do
          form.name = nil
          form.subtitle = budget_info_group.subtitle
          form.published = budget_info_group.published
          form.weight = budget_info_group.weight
          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::AdminExtended::BudgetInfoGroup, :count)
        end

        it "is valid" do
          form.name = budget_info_group.name
          form.subtitle = budget_info_group.subtitle
          form.published = budget_info_group.published
          form.weight = budget_info_group.weight
          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::AdminExtended::BudgetInfoGroup, :count).by(1)
        end
      end
    end
  end
end
