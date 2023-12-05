class AddRegionIdToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :region_id, :integer
  end
end
