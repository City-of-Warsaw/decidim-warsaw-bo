# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update budget info group.
      class BudgetInfoGroupForm < Form

        attribute :name, String
        attribute :subtitle, String
        attribute :published, Boolean
        attribute :weight, Integer

        mimic :budget_info_group

        validates :name, :weight, presence: true
        validates :published, inclusion: { in: [true, false] }
      end
    end
  end
end
