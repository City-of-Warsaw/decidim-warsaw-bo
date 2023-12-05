# This migration comes from decidim_admin_extended (originally 20211216192352)
class AddOdlIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :old_id, :integer
  end
end
