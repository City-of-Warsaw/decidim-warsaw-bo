class ChangePrecisionOfFutureMaintenance < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_projects_projects, :future_maintenance_value, :decimal, :precision => 8, :scale => 2
  end
end
