# This migration comes from decidim_proposals_extended (originally 20211102112744)
class AddMoreFieldsToPropositions < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_proposals_proposals do |t|
      t.text :nececisty_description
      t.text :category_ids
      t.text :potential_recipient_ids
      t.text :localization_info
      t.integer :total_budget_value, default: 0

      t.string :endorsment_list
      t.jsonb :autors_data
    end
  end
end
