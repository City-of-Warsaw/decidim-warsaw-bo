class AddRolesToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_documents, :coordinators, :boolean, default: false
    add_column :decidim_admin_extended_documents, :sub_coordinators, :boolean, default: false
    add_column :decidim_admin_extended_documents, :werificators, :boolean, default: false
    add_column :decidim_admin_extended_documents, :editors, :boolean, default: false
  end
end
