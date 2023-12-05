class AddSignedByCoauthorsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :signed_by_coauthor1, :boolean, default: nil
    add_column :decidim_projects_projects, :signed_by_coauthor2, :boolean, default: nil
  end
end
