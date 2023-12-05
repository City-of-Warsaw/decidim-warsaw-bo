class AddOldIdToSimpleUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_simple_users, :old_id, :integer
  end
end
