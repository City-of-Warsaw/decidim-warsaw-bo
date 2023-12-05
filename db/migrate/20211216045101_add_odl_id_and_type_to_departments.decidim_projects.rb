# This migration comes from decidim_projects (originally 20211216045013)
class AddOdlIdAndTypeToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_departments, :old_id, :integer
    add_column :decidim_admin_extended_departments, :old_type, :string
  end
end
