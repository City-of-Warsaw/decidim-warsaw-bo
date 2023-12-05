# This migration comes from decidim_projects (originally 20221028105801)
class AddConflictStateToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :conflict_status, :integer, default: 0
  end
end
