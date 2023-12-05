class AddOldIdForMigrations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :old_id, :integer # region,
    add_column :decidim_scope_types, :old_id, :integer
    add_column :decidim_projects_projects, :old_id, :integer
    # add_column :decidim_participatory_processes, :old_id, :integer
    # add_column :decidim_projects_project_recipients, :old_id, :integer
  end
end
