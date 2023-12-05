class CreateDecidimAdminExtendedRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_recipients do |t|
      t.string :name
      t.timestamps
    end
  end
end
