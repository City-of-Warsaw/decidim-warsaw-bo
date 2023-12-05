class AddActiveToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_departments, :active, :boolean, default: false
  end
end
