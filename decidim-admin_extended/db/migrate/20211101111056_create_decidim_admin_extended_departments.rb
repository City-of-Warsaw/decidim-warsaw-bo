class CreateDecidimAdminExtendedDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_departments do |t|
      t.jsonb :name
      t.string :ad_name
      # t.belongs_to :parent, null: true, foreign_key: { to_table: :decidim_admin_extended_departments }
      t.timestamps
    end
  end
end
