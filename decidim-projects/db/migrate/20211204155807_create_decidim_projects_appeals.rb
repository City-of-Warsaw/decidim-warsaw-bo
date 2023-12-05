class CreateDecidimProjectsAppeals < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_appeals do |t|
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }
      t.references :evaluator, foreign_key: { to_table: :decidim_users }
      t.text :body
      t.date :time_of_submit

      t.timestamps
    end
  end
end
