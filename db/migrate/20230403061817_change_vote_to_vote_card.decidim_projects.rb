# This migration comes from decidim_projects (originally 20230403061340)
class ChangeVoteToVoteCard < ActiveRecord::Migration[5.2]
  def change
    rename_table :decidim_projects_votes, :decidim_projects_vote_cards
  end
end
