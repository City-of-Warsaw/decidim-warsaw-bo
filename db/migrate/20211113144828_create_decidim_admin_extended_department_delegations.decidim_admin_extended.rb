# This migration comes from decidim_admin_extended (originally 20211113144341)
class CreateDecidimAdminExtendedDepartmentDelegations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_department_delegations do |t|
      t.integer :from_department_id
      t.integer :to_department_id
      t.timestamps
    end
  end
end
