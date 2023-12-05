# This migration comes from decidim_projects (originally 20230710064822)
class AddStatsToVoteCards < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :verification_results, :json, default: {}
  end
end
