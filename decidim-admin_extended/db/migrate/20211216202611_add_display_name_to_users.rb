class AddDisplayNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :display_name, :string
  end
end
