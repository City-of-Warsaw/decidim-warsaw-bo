class CreateDecidimProjectsProjectDepartmentAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_department_assignments do |t|
      t.references :department, foreign_key: { to_table: :decidim_admin_extended_departments }, index: { name: 'index_assignements_on_department_id' }
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }, index: { name: 'index_assignements_on_project_id' }
      t.timestamps
    end
  end
end
