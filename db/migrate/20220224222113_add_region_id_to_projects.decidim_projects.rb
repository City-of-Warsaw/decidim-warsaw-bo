# This migration comes from decidim_projects (originally 20220224222029)
class AddRegionIdToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :region_id, :integer
  end
end
