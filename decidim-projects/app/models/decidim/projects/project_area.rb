# frozen_string_literal: true

module Decidim::Projects
  # ProjectArea are used for many-to-many association between project and area
  class ProjectArea < ApplicationRecord
    belongs_to :project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :decidim_projects_project_id
    belongs_to :area,
               class_name: "Decidim::Area",
               foreign_key: :decidim_area_id
  end
end
