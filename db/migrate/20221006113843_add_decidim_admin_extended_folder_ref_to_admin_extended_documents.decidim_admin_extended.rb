# This migration comes from decidim_admin_extended (originally 20221006105357)
class AddDecidimAdminExtendedFolderRefToAdminExtendedDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_documents, :decidim_admin_extended_folder,
                  foreign_key: true,
                  index: { name: "index_documents_on_folder_id" }
  end
end
