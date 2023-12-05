class CustomRecipientsAndCategoriesForProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :custom_recipients, :text
    add_column :decidim_projects_projects, :custom_categories, :text
  end
end
