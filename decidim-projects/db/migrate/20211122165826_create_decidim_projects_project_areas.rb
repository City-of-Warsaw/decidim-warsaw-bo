class CreateDecidimProjectsProjectAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_areas do |t|
      t.references :decidim_projects_project, index: { name: 'index_on_areas_on_projects_id'}
      t.references :decidim_area, index: { name: 'index_on_projects_on_areas_id'}
      t.timestamps
    end
  end
end
