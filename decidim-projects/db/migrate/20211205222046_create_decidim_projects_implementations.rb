class CreateDecidimProjectsImplementations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_implementations do |t|
      t.text :body
      t.references :user, foreign_key: { to_table: :decidim_users }
      t.references :project, foreign_key: { to_table: :decidim_projects_projects }
      t.date :implementation_date
      t.timestamps
    end
  end
end
