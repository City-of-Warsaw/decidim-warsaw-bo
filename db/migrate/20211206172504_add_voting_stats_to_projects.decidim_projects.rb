# This migration comes from decidim_projects (originally 20211206172215)
class AddVotingStatsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :votes_count, :integer
    add_column :decidim_projects_projects, :votes_percentage, :decimal, precision: 10, scale: 2
  end
end
