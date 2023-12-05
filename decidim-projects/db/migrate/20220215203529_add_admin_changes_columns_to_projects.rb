class AddAdminChangesColumnsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :admin_changes, :jsonb
  end
end
