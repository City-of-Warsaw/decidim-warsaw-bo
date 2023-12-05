# This migration comes from decidim_proposals_extended (originally 20211114160839)
class CreateDecidimProposalsExtendedEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_proposals_extended_evaluations do |t|
      t.integer :proposal_id
      t.integer :user_id
      t.string :type
      t.jsonb :details
      t.timestamps
    end
  end
end
