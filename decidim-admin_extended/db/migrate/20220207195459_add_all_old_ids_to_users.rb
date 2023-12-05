class AddAllOldIdsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :all_old_ids, :string
  end
end
