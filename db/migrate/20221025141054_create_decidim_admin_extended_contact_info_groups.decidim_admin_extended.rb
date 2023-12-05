# This migration comes from decidim_admin_extended (originally 20221025140330)
class CreateDecidimAdminExtendedContactInfoGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_contact_info_groups do |t|
      t.string :name
      t.string :subtitle
      t.boolean :published
      t.integer :weight

      t.timestamps
    end
  end
end
