class AddFactualBudgetValueToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :factual_budget_value, :integer
  end
end
