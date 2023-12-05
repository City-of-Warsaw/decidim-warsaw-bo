class CreateStatisticsParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_statistics_participatory_processes do |t|
      t.integer :scope_id
      t.integer :participatory_process_id
      t.integer :number_of_project_voters_0_18
      t.integer :number_of_project_voters_19_24
      t.integer :number_of_project_voters_25_34
      t.integer :number_of_project_voters_35_44
      t.integer :number_of_project_voters_45_64
      t.integer :number_of_project_voters_65_100
      t.timestamps
    end
    add_index :decidim_projects_statistics_participatory_processes, :scope_id, name: 'statistics_participatory_processes_scope_id'
    add_index :decidim_projects_statistics_participatory_processes, :participatory_process_id, name: 'statistics_participatory_processes_process_id'
    add_index :decidim_projects_statistics_participatory_processes, [:scope_id, :participatory_process_id], name: 'statistics_participatory_processes_uniq_scope', unique: true
  end
end
