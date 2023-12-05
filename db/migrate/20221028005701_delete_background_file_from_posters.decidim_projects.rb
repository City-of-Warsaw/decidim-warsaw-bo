# This migration comes from decidim_projects (originally 20221028005527)
class DeleteBackgroundFileFromPosters < ActiveRecord::Migration[5.2]
  def up
    remove_column :decidim_projects_poster_templates, :background_file
  end

  def down
    add_column :decidim_projects_poster_templates, :background_file, :string
  end
end
