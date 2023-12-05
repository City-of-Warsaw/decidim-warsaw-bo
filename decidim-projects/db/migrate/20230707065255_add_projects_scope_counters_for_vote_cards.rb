class AddProjectsScopeCountersForVoteCards < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :district_projects_count, :integer, default: 0
    add_column :decidim_projects_vote_cards, :global_projects_count, :integer, default: 0
  end
end
