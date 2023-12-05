# This migration comes from decidim_projects (originally 20220825155448)
class CreateDecidimProjectsProjectRanks < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_ranks do |t|
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }, index: true
      t.references :scope, foreign_key: { to_table: :decidim_scopes }, index: true

      t.integer :valid_votes_count
      t.integer :not_verified_votes_count
      t.integer :invalid_votes_count
      t.integer :votes_in_paper_count
      t.integer :votes_electronic_count
      t.decimal :percentage_of_not_verified_votes, precision: 5, scale: 2

      t.boolean :winner, default: false

      t.timestamps
    end
  end
end
