# This migration comes from decidim_core_extended (originally 20220927091657)
class CreateDecidimCoreExtendedNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_core_extended_notes do |t|
      t.references :user, foreign_key: { to_table: :decidim_users }, index: true

      t.string :title
      t.string :body

      t.timestamps
    end
  end
end
