class RenameComponentColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_projects, :component_id, :decidim_component_id
  end
end
