class CreateDecidimAdminExtendedDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_documents do |t|
      t.string :name
      t.string :folder

      t.timestamps
    end
  end
end
