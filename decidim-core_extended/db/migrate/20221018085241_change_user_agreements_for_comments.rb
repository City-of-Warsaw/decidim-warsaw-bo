class ChangeUserAgreementsForComments < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_users, :inform_me_about_comments, :boolean, default: nil

    remove_column :decidim_users, :inform_about_my_projects_comments
    remove_column :decidim_users, :inform_about_participated_comments
  end

  def down
    remove_column :decidim_users, :inform_me_about_comments

    add_column :decidim_users, :inform_about_my_projects_comments, :boolean, default: nil
    add_column :decidim_users, :inform_about_participated_comments, :boolean, default: nil
  end
end
