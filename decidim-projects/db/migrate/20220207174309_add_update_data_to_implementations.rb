class AddUpdateDataToImplementations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_implementations, :update_data, :jsonb
  end
end
