# This migration comes from decidim_projects (originally 20211126192623)
class CreateDecidimProjectsProjectUserAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_user_assignments do |t|
      t.references :user, foreign_key: { to_table: :decidim_users }, index: { name: 'index_departments_on_project_id' }
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }, index: { name: 'index_projects_on_department_id' }
      t.timestamps
    end
  end
end
