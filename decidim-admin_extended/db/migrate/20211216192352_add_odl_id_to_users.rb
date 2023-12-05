class AddOdlIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :old_id, :integer
  end
end
