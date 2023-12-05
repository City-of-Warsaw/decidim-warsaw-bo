class AddFolderRefFromAdminExtendedDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_documents, :folder
  end
end
