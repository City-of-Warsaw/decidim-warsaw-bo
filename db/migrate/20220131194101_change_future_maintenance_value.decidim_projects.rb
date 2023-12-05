# This migration comes from decidim_projects (originally 20220131194012)
class ChangeFutureMaintenanceValue < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_projects_projects, :future_maintenance_value, :decimal, :precision => 14, :scale => 2
  end
end
