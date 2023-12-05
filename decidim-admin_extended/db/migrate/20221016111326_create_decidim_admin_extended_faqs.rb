class CreateDecidimAdminExtendedFaqs < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_faqs do |t|
      t.string :title
      t.string :content
      t.integer :weight

      t.timestamps
    end
  end
end
