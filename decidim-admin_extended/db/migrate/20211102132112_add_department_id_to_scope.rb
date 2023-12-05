class AddDepartmentIdToScope < ActiveRecord::Migration[5.2]
  def change
    # add_reference :decidim_scopes, :decidim_admin_extended_department, index: true, foreign_key: true
    add_column :decidim_scopes, :department_id, :integer
  end
end
