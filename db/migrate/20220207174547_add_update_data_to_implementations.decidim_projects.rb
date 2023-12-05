# This migration comes from decidim_projects (originally 20220207174309)
class AddUpdateDataToImplementations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_implementations, :update_data, :jsonb
  end
end
