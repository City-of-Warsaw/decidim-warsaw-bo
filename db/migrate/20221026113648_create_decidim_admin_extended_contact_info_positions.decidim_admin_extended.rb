# This migration comes from decidim_admin_extended (originally 20221026112722)
class CreateDecidimAdminExtendedContactInfoPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_contact_info_positions do |t|
      t.string :name
      t.string :position
      t.string :phone
      t.string :email
      t.boolean :published
      t.integer :weight, default: 1
      t.references :contact_info_group, index: { name: "index_contact_positions_on_group_id" }

      t.timestamps
    end
  end
end
