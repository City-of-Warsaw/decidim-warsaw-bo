# frozen_string_literal: true

module Decidim::Projects
  # Implementation are used by users in admin panel to show Project's real life execution and effects.
  class Implementation < ApplicationRecord
    belongs_to :project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :project_id
    belongs_to :user,
               class_name: "Decidim::User",
               foreign_key: :user_id

    scope :ordered, -> { order('implementation_date asc') }
    scope :visible, -> { where.not(implementation_date: nil).where('implementation_date <= ?', DateTime.current )}
  end
end
