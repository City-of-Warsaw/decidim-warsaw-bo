# This migration comes from decidim_projects (originally 20220804111934)
class AddLimitsOnProjectsVotesToProcess < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_participatory_processes do |t|
      t.integer :global_scope_projects_voting_limit, default: 15
      t.integer :district_scope_projects_voting_limit, default: 10

      t.integer :minimum_global_scope_projects_votes, default: 50
      t.integer :minimum_district_scope_projects_votes, default: 100
    end
  end
end
