class AddStatsToVoteCards < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :verification_results, :json, default: {}
  end
end
