# This migration comes from decidim_admin_extended (originally 20221114083800)
class AddOnMainSiteToBudgetInfoPosition < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_budget_info_positions, :on_main_site, :boolean, default: false
  end
end
