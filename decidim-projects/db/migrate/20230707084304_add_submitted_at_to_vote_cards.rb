class AddSubmittedAtToVoteCards < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :submitted_at, :datetime
  end
end
