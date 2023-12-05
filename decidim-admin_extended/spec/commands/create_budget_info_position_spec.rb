# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe CreateBudgetInfoPosition do
        let(:command) { described_class.new(form) }
        let(:budget_info_group) { create(:budget_info_group)}
        let(:budget_info_position) { create(:budget_info_position)}
        let(:form) { Admin::BudgetInfoPositionForm.new }

        it "is not valid" do
          form.name = nil
          form.description = budget_info_position.description
          form.amount = budget_info_position.amount
          form.published = budget_info_position.published
          form.weight = budget_info_position.weight
          form.budget_info_group_id = budget_info_position.budget_info_group_id
          form.on_main_site = budget_info_position.on_main_site

          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::AdminExtended::BudgetInfoPosition, :count)
        end

        it "is valid" do
          form.name = budget_info_position.name
          form.description = budget_info_position.description
          form.amount = budget_info_position.amount
          form.published = budget_info_position.published
          form.weight = budget_info_position.weight
          form.budget_info_group_id = budget_info_position.budget_info_group_id
          form.on_main_site = budget_info_position.on_main_site

          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::AdminExtended::BudgetInfoPosition, :count).by(1)
        end
      end
    end
  end
end
