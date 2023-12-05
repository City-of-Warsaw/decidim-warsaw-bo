# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe UpdateBudgetInfoGroup do
        let(:command) { described_class.new(budget_info_group, form) }
        let(:budget_info_group) { create(:budget_info_group) }
        let(:form) { Admin::BudgetInfoGroupForm.new }

        it "is not valid" do
          form.name = budget_info_group.name
          form.subtitle = budget_info_group.subtitle
          form.published = nil
          form.weight = budget_info_group.weight
          expect { command.call }.to broadcast(:invalid)
        end

        it "is valid" do
          form.name = 'group_name'
          form.subtitle = 'description'
          form.published = false
          form.weight = 3
          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end

