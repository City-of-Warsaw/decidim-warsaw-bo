# This migration comes from decidim_proposals_extended (originally 20211113191703)
class AddAdminVerifStatusesToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :admin_verification_status1, :string, default: nil
    add_column :decidim_proposals_proposals, :admin_verification_status2, :string, default: nil
  end
end
