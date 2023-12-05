class RemoveDecidimAdminExtendedFolderRefFromAdminExtendedDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_reference :decidim_admin_extended_documents, :decidim_admin_extended_folder,
                  foreign_key: true,
                  index: false
  end
end
