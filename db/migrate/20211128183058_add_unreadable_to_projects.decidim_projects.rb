# This migration comes from decidim_projects (originally 20211128182914)
class AddUnreadableToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :unreadable, :boolean, default: nil
  end
end
