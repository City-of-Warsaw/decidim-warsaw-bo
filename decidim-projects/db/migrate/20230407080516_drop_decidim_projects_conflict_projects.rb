class DropDecidimProjectsConflictProjects < ActiveRecord::Migration[5.2]
  def up
    drop_table :decidim_projects_conflict_projects
  end

  def down
    create_table :decidim_projects_conflict_projects do |t|
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }, index: true
      t.references :second_project, foreign_key: { to_table: :decidim_projects_projects }, index: true

      t.timestamps
    end
  end
end
