class AddScopingFieldsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :chosen_for_voting, :boolean, default: false
    add_column :decidim_projects_projects, :chosen_for_implementation, :boolean, default: false
  end
end
