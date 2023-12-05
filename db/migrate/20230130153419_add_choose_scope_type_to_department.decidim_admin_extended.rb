# This migration comes from decidim_admin_extended (originally 20230130153241)
class AddChooseScopeTypeToDepartment < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_departments, :department_type, :integer, default: nil

    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::Department.update_all department_type: 'districts'
      end
    end
  end
end
