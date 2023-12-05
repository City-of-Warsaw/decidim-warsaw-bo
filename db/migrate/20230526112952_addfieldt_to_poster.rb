class AddfieldtToPoster < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_poster_templates, :project_number_height, :integer, default: 0
    add_column :decidim_projects_poster_templates, :project_area_height, :integer, default: 0
  end
end
