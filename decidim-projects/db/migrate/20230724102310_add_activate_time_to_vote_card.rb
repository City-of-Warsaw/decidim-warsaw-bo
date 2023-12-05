class AddActivateTimeToVoteCard < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards,:activated_at,:datetime
  end
end
