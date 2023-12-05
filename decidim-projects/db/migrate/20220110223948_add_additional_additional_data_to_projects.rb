class AddAdditionalAdditionalDataToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :additional_data, :jsonb, default: {}
  end
end
