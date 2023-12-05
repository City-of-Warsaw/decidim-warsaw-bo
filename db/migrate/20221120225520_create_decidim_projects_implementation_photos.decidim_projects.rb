# This migration comes from decidim_projects (originally 20221120222553)
class CreateDecidimProjectsImplementationPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_implementation_photos do |t|
      t.belongs_to :project
      t.string :image_alt
      t.integer :weight, default: 0
      t.boolean :main_attachment, default: :false
      t.timestamps
    end
  end
end
