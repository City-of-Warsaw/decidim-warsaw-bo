# This migration comes from decidim_admin_extended (originally 20220207195459)
class AddAllOldIdsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :all_old_ids, :string
  end
end
