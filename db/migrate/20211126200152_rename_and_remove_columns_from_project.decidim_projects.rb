# This migration comes from decidim_projects (originally 20211126200030)
class RenameAndRemoveColumnsFromProject < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_projects, :admin_verification_status1, :verification_status
    remove_column :decidim_projects_projects, :admin_verification_status2
  end
end
