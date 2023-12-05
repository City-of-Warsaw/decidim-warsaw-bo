class CreateDecidimAdminExtendedBudgetInfoPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_budget_info_positions do |t|
      t.string :name
      t.string :description
      t.string :amount
      t.string :file
      t.boolean :published
      t.integer :weight, default: 1

      t.timestamps
    end
  end
end
