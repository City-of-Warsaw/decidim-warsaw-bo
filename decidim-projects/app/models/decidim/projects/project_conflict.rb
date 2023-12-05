# frozen_string_literal: true

module Decidim::Projects
  # ProjectConflict us used for many-to-many association between two projects, to provide connection for projects,
  # that can not be realized at the same time, and in consequence cannot be together on a ranking list.
  # When created, the other part of connection is added as well.
  class ProjectConflict < ApplicationRecord
    belongs_to :project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :project_id

    belongs_to :second_project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :second_project_id
  end
end
