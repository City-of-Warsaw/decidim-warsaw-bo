# This migration comes from decidim_users_extended (originally 20211114175733)
class UpdateUserNameFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_users, :user_name, :first_name
    rename_column :decidim_users, :user_surname, :last_name
  end
end
