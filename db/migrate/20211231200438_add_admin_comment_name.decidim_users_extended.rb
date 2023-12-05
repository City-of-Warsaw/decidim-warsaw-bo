# This migration comes from decidim_users_extended (originally 20211231200340)
class AddAdminCommentName < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :admin_comment_name, :string
  end
end
