# This migration comes from decidim_proposals_extended (originally 20211113204347)
class ChangeRankNumberToVoting < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_proposals_proposals, :rank_number, :voting_number
  end
end
