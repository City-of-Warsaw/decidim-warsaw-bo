# This migration comes from decidim_projects (originally 20211220031515)
class AddEndorsmentsAndCostsFieldToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :contractors_and_costs, :string
  end
end
