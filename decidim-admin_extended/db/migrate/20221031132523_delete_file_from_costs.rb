class DeleteFileFromCosts < ActiveRecord::Migration[5.2]
  def up
    remove_column :decidim_admin_extended_budget_info_positions, :file
  end

  def down
    add_column :decidim_admin_extended_budget_info_positions, :file, :string
  end
end
