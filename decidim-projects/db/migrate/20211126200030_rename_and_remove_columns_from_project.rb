class RenameAndRemoveColumnsFromProject < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_projects, :admin_verification_status1, :verification_status
    remove_column :decidim_projects_projects, :admin_verification_status2
  end
end
