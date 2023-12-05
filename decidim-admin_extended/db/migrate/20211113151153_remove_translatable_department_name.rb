class RemoveTranslatableDepartmentName < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_admin_extended_departments CASCADE;")

      dir.up do
        change_column :decidim_admin_extended_departments, :name, :string
      end
      dir.down do
        change_column :decidim_admin_extended_departments, :name, :jsonb
      end
    end
  end
end
