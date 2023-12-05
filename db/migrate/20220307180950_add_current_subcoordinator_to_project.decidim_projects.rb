# This migration comes from decidim_projects (originally 20220307180738)
class AddCurrentSubcoordinatorToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :current_sub_coordinator_id, :integer
  end
end
