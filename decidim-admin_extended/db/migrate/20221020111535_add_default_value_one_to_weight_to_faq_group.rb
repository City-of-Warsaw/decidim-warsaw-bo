class AddDefaultValueOneToWeightToFaqGroup < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_faq_groups, :weight, 1
  end
end
