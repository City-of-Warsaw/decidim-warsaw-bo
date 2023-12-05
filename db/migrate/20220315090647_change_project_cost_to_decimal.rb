class ChangeProjectCostToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_projects_projects, :budget_value, :decimal, :precision => 14, :scale => 2
  end
end
