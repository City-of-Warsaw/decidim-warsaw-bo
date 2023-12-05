class AddAdminCommentName < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :admin_comment_name, :string
  end
end
