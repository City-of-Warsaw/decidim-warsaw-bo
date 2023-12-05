class AddOffensiveToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :offensive, :boolean, default: false
  end
end
