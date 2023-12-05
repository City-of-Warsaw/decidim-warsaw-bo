# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update budget info position.
      class BudgetInfoPositionForm < Form
        include ::Decidim::HasUploadValidations

        attribute :name, String
        attribute :description, String
        attribute :amount, String
        attribute :file
        attribute :published, Boolean
        attribute :weight, Integer
        attribute :on_main_site, Boolean

        attribute :budget_info_group_id, Integer

        mimic :budget_info_position

        validates :name, :description, :weight, :budget_info_group_id, presence: true
        validates :published, inclusion: { in: [true, false] }
        validates :file, passthru: { to: BudgetInfoPosition }
      end
    end
  end
end
