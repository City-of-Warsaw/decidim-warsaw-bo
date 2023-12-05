# This migration comes from decidim_admin_extended (originally 20221010123122)
class AddFolderRefFromAdminExtendedDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_documents, :folder
  end
end
