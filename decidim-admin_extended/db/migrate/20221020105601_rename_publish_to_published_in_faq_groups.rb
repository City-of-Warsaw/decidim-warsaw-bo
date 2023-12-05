class RenamePublishToPublishedInFaqGroups < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_admin_extended_faq_groups, :publish, :published
  end
end
