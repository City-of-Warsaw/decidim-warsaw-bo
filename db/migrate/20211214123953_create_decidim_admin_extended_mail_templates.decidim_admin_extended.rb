# This migration comes from decidim_admin_extended (originally 20211214122227)
class CreateDecidimAdminExtendedMailTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_mail_templates do |t|
      t.string :name
      t.string :system_name
      t.text :body
      t.timestamps
    end
  end
end
