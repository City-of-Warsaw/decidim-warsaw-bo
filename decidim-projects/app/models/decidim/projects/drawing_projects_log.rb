# frozen_string_literal: true

module Decidim::Projects
  class DrawingProjectsLog < ApplicationRecord

    belongs_to :scope,
               class_name: "Decidim::Scope",
               foreign_key: :scope_id,
               optional: true

    def all_projects
      Project.where(id: all_project_ids)
    end

    def winning_project
      Project.where(id: winning_project_ids)
    end
  end
end
