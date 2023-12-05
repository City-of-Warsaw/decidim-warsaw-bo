class AddLocationsToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :locations, :jsonb, null: false, default: {}
  end
end
