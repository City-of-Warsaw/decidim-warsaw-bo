# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe UpdateBudgetInfoPosition do
        let(:command) { described_class.new(budget_info_position, form) }
        let(:budget_info_group) { create(:budget_info_group)}
        let(:budget_info_group_second) { create(:budget_info_group)}
        let(:budget_info_position) { create(:budget_info_position)}
        let(:form) { Admin::BudgetInfoPositionForm.new }

        it "is not valid" do
          form.name = budget_info_position.name
          form.description = budget_info_position.description
          form.amount = budget_info_position.amount
          form.published = nil
          form.weight = budget_info_position.weight
          form.budget_info_group_id = budget_info_position.budget_info_group_id
          form.on_main_site = budget_info_position.on_main_site

          expect { command.call }.to broadcast(:invalid)
        end

        it "is valid" do
          form.name = "second name"
          form.description = "second description"
          form.amount = "second amount"
          form.published = false
          form.weight = 2
          form.budget_info_group_id = budget_info_group_second.id
          form.on_main_site = false

          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end
