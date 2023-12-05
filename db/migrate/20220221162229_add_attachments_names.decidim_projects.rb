# This migration comes from decidim_projects (originally 20220221162101)
class AddAttachmentsNames < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :public_attachment_names, :string, after: :category_names
    add_column :decidim_projects_projects, :all_attachment_names, :string, after: :category_names
  end
end
