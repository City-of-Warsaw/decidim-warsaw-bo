# frozen_string_literal: true

module Decidim::Projects
  # ProjectDepartmentAssignment are used for many-to-many association between project and department
  class ProjectDepartmentAssignment < ApplicationRecord
    belongs_to :department,
              class_name: "Decidim::AdminExtended::Department",
              foreign_key: :department_id
    belongs_to :project,
              class_name: "Decidim::Projects::Project",
              foreign_key: :project_id
  end
end
