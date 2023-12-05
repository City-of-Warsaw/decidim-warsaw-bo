class AddDefaultFalseToPublishToFaqGroup < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_faq_groups, :publish, false
  end
end
