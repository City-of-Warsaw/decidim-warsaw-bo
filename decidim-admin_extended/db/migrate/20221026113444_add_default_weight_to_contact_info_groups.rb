class AddDefaultWeightToContactInfoGroups < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_contact_info_groups, :weight, 1
  end
end
