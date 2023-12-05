class CreateDecidimAdminExtendedFaqGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_faq_groups do |t|
      t.string :title
      t.string :subtitle
      t.boolean :publish
      t.integer :weight

      t.timestamps
    end
  end
end
