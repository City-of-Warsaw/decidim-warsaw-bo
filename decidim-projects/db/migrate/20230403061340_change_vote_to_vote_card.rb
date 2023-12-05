class ChangeVoteToVoteCard < ActiveRecord::Migration[5.2]
  def change
    rename_table :decidim_projects_votes, :decidim_projects_vote_cards
  end
end
