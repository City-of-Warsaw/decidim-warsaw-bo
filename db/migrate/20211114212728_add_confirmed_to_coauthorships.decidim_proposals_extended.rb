# This migration comes from decidim_proposals_extended (originally 20211114212606)
class AddConfirmedToCoauthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_coauthorships, :confirmed, :boolean, default: true
  end
end
