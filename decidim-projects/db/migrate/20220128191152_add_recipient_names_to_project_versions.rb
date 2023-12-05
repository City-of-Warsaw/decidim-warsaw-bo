class AddRecipientNamesToProjectVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :recipient_names, :string
    add_column :decidim_projects_projects, :category_names, :string
  end
end
