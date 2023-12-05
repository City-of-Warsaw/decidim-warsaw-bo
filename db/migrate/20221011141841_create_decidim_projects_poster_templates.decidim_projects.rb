# This migration comes from decidim_projects (originally 20221011105426)
class CreateDecidimProjectsPosterTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_poster_templates do |t|

      t.string :title
      t.string :subtitle
      t.boolean :publish
      t.references :decidim_participatory_process, index: { name: "poster_templates_on_decidim_participatory_process_id" }
      t.integer :width, default: 0
      t.integer :height, default: 0
      t.string :background_file
      t.integer :project_title_x, default: 0
      t.integer :project_title_y, default: 0
      t.integer :project_title_width, default: 0
      t.string :project_title_css
      t.integer :project_area_x, default: 0
      t.integer :project_area_y, default: 0
      t.integer :project_area_width, default: 0
      t.string :project_area_css
      t.integer :project_number_x, default: 0
      t.integer :project_number_y, default: 0
      t.integer :project_number_width, default: 0
      t.string :project_number_css
      t.string :body_css

      t.timestamps
    end
  end
end
