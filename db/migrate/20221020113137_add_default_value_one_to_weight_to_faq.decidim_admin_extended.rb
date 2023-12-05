# This migration comes from decidim_admin_extended (originally 20221020113050)
class AddDefaultValueOneToWeightToFaq < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_faqs, :weight, 1
  end
end
