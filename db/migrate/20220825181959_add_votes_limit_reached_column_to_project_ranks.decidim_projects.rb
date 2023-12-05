# This migration comes from decidim_projects (originally 20220825181258)
class AddVotesLimitReachedColumnToProjectRanks < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_project_ranks, :votes_limit_reached, :boolean, default: false
  end
end
