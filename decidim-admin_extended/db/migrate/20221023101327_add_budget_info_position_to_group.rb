class AddBudgetInfoPositionToGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_budget_info_positions, :budget_info_group, index: { name: "index_positions_on_group_id" }
  end
end
