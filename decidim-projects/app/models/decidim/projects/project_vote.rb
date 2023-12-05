# frozen_string_literal: true

module Decidim::Projects
  # ProjectVote is used for many-to-many association between project and vote
  # to assign list of projects to single vote
  class ProjectVote < ApplicationRecord
    include Decidim::Traceable


    belongs_to :project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :decidim_projects_project_id
    belongs_to :vote_card,
               class_name: "Decidim::Projects::VoteCard",
               foreign_key: :decidim_projects_vote_card_id
  end
end
