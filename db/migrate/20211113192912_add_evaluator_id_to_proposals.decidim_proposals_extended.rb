# This migration comes from decidim_proposals_extended (originally 20211113192627)
class AddEvaluatorIdToProposals < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_proposals_proposals, :evaluator, foreign_key: { to_table: :decidim_users }
  end
end
