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
