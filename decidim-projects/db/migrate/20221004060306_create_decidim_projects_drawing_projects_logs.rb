class CreateDecidimProjectsDrawingProjectsLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_drawing_projects_logs do |t|
      t.bigint :all_project_ids, array: true, default: []
      t.bigint :winning_project_ids, array: true, default: []
      t.timestamps
    end
    add_column :decidim_projects_project_ranks, :drawing_projects_log_id, :bigint
  end
end
