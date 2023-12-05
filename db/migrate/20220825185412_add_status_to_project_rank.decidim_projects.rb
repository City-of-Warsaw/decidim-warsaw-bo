# This migration comes from decidim_projects (originally 20220825185339)
class AddStatusToProjectRank < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_project_ranks, :status, :string
  end
end
