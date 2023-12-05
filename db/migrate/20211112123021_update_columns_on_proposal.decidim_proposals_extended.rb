# This migration comes from decidim_proposals_extended (originally 20211112122350)
class UpdateColumnsOnProposal < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_proposals_proposals, :category_ids
    remove_column :decidim_proposals_proposals, :potential_recipient_ids
    remove_column :decidim_proposals_proposals, :autors_data

    add_column :decidim_proposals_proposals, :coauthor_email_one, :string
    add_column :decidim_proposals_proposals, :coauthor_email_two, :string
    add_column :decidim_proposals_proposals, :year, :integer
  end
end
