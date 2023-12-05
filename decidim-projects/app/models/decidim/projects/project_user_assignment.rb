# frozen_string_literal: true

module Decidim::Projects
  # ProjectUserAssignment are used for many-to-many association between project and user.
  class ProjectUserAssignment < ApplicationRecord
    belongs_to :project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :project_id
    belongs_to :user,
               class_name: "Decidim::User",
               foreign_key: :user_id
  end
end
