class AddActiveColumnToRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_recipients, :active, :boolean, default: true
  end
end
