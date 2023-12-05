# This migration comes from decidim_projects (originally 20220218181752)
class AddFactualBudgetValueToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :factual_budget_value, :integer
  end
end
