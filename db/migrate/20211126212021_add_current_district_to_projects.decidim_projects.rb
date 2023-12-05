# This migration comes from decidim_projects (originally 20211126210913)
class AddCurrentDistrictToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :current_department_id, :integer
  end
end
