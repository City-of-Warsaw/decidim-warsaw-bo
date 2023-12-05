# This migration comes from decidim_projects (originally 20211129212325)
class AddResultsFieldsToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :formal_result, :boolean, default: nil, null: true
    add_column :decidim_projects_projects, :meritorical_result, :boolean, default: nil, null: true
    add_column :decidim_projects_projects, :reevaluation_result, :boolean, default: nil, null: true
  end
end
