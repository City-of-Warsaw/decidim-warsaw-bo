# This migration comes from decidim_projects (originally 20220801101752)
class CreateDecidimProjectsProjectVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_votes do |t|
      t.references :decidim_projects_project, index: { name: 'index_on_votes_on_project_id' }
      t.references :decidim_projects_vote, index: { name: 'index_on_projects_on_vote_id' }

      t.timestamps
    end
  end
end
