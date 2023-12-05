# This migration comes from decidim_projects (originally 20211206205803)
class CreateDecidimProjectsRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_regions do |t|
      t.string :name
      t.integer :old_id
      t.timestamps
    end
  end
end
