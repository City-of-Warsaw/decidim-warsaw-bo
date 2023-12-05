# This migration comes from decidim_admin_extended (originally 20221201194650)
class AddActiveToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_departments, :active, :boolean, default: false
  end
end
