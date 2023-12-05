# This migration comes from decidim_projects (originally 20230627090752)
class AddPercentageOfNotVerifiedVotesToRanks < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_project_ranks, :percentage_of_scope_votes, :decimal, precision: 5, scale: 2
  end
end
