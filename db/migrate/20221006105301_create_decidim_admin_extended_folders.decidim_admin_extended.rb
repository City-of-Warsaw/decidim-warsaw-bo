# This migration comes from decidim_admin_extended (originally 20221006083051)
class CreateDecidimAdminExtendedFolders < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_folders do |t|
      t.string :name

      t.timestamps
    end
  end
end
