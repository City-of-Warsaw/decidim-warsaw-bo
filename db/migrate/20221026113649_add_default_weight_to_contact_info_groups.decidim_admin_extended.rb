# This migration comes from decidim_admin_extended (originally 20221026113444)
class AddDefaultWeightToContactInfoGroups < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_contact_info_groups, :weight, 1
  end
end
