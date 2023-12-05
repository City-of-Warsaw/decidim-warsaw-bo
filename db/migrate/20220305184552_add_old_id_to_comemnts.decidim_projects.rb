# This migration comes from decidim_projects (originally 20220305184514)
class AddOldIdToComemnts < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :old_id, :integer
  end
end
