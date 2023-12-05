# This migration comes from decidim_projects (originally 20220829113737)
class CreateDecidimProjectsConflictProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_conflict_projects do |t|
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }, index: true
      t.references :second_project, foreign_key: { to_table: :decidim_projects_projects }, index: true
      
      t.timestamps
    end
  end
end
