# This migration comes from decidim_projects (originally 20221006203734)
class AddVotesCountToProjectRank < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_project_ranks, :votes_count, :integer, default: 0
  end
end
