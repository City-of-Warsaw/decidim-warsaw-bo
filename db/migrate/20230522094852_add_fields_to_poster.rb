class AddFieldsToPoster < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_poster_templates, :sample_title, :text
    add_column :decidim_projects_poster_templates, :sample_project_number, :text
    add_column :decidim_projects_poster_templates, :sample_project_area, :text

    add_column :decidim_projects_poster_templates, :project_title_height, :integer, default: 0
  end
end
