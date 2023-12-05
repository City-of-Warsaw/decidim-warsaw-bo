class CreateDecidimProjectsProjectConflicts < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_conflicts do |t|
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }, index: true
      t.references :second_project, foreign_key: { to_table: :decidim_projects_projects }, index: true
    end
  end
end
