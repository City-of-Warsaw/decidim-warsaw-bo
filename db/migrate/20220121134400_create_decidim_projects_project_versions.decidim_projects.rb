# This migration comes from decidim_projects (originally 20220121132848)
class CreateDecidimProjectsProjectVersions < ActiveRecord::Migration[5.2]

  TEXT_BYTES = 1_073_741_823

  def change
    create_table :project_versions do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.text :object_changes, limit: TEXT_BYTES

      # 1 – Publiczna,
      # 2 - Tylko dla administratora – niepubliczny,
      # 3 – Oczekuje na zatwierdzenie,
      # 4 – Projekt realizowany,
      # -1 – Kopia robocza
      t.integer :visible_type, default: -1
      t.boolean :visible, default: false

      t.datetime :created_at
    end
    add_index :project_versions, [:item_type, :item_id]

  end
end
