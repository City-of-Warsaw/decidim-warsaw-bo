# This migration comes from decidim_projects (originally 20220311120746)
class AddCoauthorsDataToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :coauthors_data, :jsonb, default: {}
  end
end
