# This migration comes from decidim_projects (originally 20230724102310)
class AddActivateTimeToVoteCard < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards,:activated_at,:datetime
  end
end
