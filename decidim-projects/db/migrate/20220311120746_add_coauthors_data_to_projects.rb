class AddCoauthorsDataToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :coauthors_data, :jsonb, default: {}
  end
end
