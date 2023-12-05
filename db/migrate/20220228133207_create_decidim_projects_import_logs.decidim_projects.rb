# This migration comes from decidim_projects (originally 20220228132931)
class CreateDecidimProjectsImportLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_import_logs do |t|
      t.integer :old_id
      t.string :resource_type
      t.string :message
      t.jsonb :body
      t.timestamps
    end
  end
end
