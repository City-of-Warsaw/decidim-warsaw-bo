# This migration comes from decidim_admin_extended (originally 20221020111535)
class AddDefaultValueOneToWeightToFaqGroup < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_faq_groups, :weight, 1
  end
end
