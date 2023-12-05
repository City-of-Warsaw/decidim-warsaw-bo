# This migration comes from decidim_admin_extended (originally 20221020105601)
class RenamePublishToPublishedInFaqGroups < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_admin_extended_faq_groups, :publish, :published
  end
end
