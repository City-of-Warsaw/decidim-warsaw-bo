# This migration comes from decidim_proposals_extended (originally 20211112091138)
class AddJoinTablesForProposalsElements < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_proposals_extended_proposal_areas do |t|
      t.references :decidim_proposals_proposal, index: { name: 'index_on_areas_on_proposals_id'}
      t.references :decidim_area, index: { name: 'index_on_proposals_on_areas_id'}
      t.timestamps
    end

    create_table :decidim_proposals_extended_proposal_recipients do |t|
      t.references :decidim_proposals_proposal, index: { name: 'index_on_recipients_on_proposals_id'}
      t.references :decidim_admin_extended_recipient, index: { name: 'index_on_proposals_on_recipients_id'}

      t.timestamps
    end
  end
end
