class RemoveNameFromDocuments < ActiveRecord::Migration[5.2]
  def up
    remove_column :decidim_admin_extended_documents, :name
  end

  def down
    add_column :decidim_admin_extended_documents, :name, :string
  end
end
