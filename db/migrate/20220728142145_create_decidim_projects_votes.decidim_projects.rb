# This migration comes from decidim_projects (originally 20220728141116)
class CreateDecidimProjectsVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_votes do |t|
      t.references :decidim_component, index: { name: "decidim_component_projects_vote_id" }
      t.references :scope, index: { name: "decidim_scope_projects_vote_id" }
      # electronic voting data
      t.string :email
      t.string :status
      t.string :card_number
      t.boolean :is_paper, default: false
      t.string :voting_token
      # voter data
      t.string :first_name
      t.string :last_name
      t.string :pesel_number
      t.string :street
      t.string :street_number
      t.string :flat_number
      t.string :zip_code
      t.string :city
      # editor fields
      t.boolean :identity_confirmed, default: false
      t.boolean :card_signed, default: false

      t.boolean :data_unreadable, default: false
      t.boolean :card_invalid, default: false
      t.boolean :card_received_late, default: false
      t.timestamps
    end
  end
end
