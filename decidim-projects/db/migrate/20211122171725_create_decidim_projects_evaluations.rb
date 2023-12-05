class CreateDecidimProjectsEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_evaluations do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :type
      t.jsonb :details
      t.timestamps
    end
  end
end
