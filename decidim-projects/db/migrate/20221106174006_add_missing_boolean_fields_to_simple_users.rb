class AddMissingBooleanFieldsToSimpleUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_simple_users, :inform_about_admin_changes, :boolean, default: false
    add_column :decidim_projects_simple_users, :watched_implementations_updates, :boolean, default: false
    add_column :decidim_projects_simple_users, :newsletter, :boolean, default: false
    add_column :decidim_projects_simple_users, :inform_me_about_comments, :boolean, default: false
    add_column :decidim_projects_simple_users, :allow_private_message, :boolean, default: false
  end
end
