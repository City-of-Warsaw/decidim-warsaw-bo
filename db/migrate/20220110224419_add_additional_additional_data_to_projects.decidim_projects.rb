# This migration comes from decidim_projects (originally 20220110223948)
class AddAdditionalAdditionalDataToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :additional_data, :jsonb, default: {}
  end
end
