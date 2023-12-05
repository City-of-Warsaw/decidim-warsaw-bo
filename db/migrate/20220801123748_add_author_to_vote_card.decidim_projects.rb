# This migration comes from decidim_projects (originally 20220801123637)
class AddAuthorToVoteCard < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :author_id, :integer
  end
end
