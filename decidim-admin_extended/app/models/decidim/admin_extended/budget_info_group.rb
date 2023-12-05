# frozen_string_literal: true

module Decidim::AdminExtended
  # BudgetInfoGroup is used to:
  # - provide has_many association for various BudgetInfoPositions
  # - to store data: groupes which store positions
  class BudgetInfoGroup < ApplicationRecord
    has_many :budget_info_positions,
             class_name: "Decidim::AdminExtended::BudgetInfoPosition",
             foreign_key: :budget_info_group_id
    has_many :published_budget_info_positions, -> { published.sorted_by_weight.with_attached_file },
             class_name: "Decidim::AdminExtended::BudgetInfoPosition"
             
    scope :published, -> { where(published: true) }
    scope :sorted_by_weight, -> { order(:weight) }  
  end
end
