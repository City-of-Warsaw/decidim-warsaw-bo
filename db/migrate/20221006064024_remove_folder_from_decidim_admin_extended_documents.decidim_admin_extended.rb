# This migration comes from decidim_admin_extended (originally 20221006063754)
class RemoveFolderFromDecidimAdminExtendedDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_admin_extended_documents, :folder, :string
  end
end
