class AddAuthorToVoteCard < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :author_id, :integer
  end
end
