# This migration comes from decidim_core_extended (originally 20221012061048)
class AddNewUserNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :allow_private_message, :boolean, default: nil
    add_column :decidim_users, :inform_about_my_projects_comments, :boolean, default: nil
    add_column :decidim_users, :inform_about_participated_comments, :boolean, default: nil
    add_column :decidim_users, :newsletter, :boolean, default: nil
    add_column :decidim_users, :implementations_updates, :boolean, default: nil
    add_column :decidim_users, :watched_implementations_updates, :boolean, default: nil
    add_column :decidim_users, :inform_about_admin_changes, :boolean, default: nil
  end
end
