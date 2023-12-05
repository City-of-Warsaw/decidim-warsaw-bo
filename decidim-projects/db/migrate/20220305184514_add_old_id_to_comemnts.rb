class AddOldIdToComemnts < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :old_id, :integer
  end
end
