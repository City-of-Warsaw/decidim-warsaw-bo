# This migration comes from decidim_projects (originally 20211201050550)
class AddImplementationOnMain < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :implementation_on_main_site, :boolean, default: false
  end
end
