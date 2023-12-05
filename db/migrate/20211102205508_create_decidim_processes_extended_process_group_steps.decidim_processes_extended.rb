# This migration comes from decidim_processes_extended (originally 20211102205341)
class CreateDecidimProcessesExtendedProcessGroupSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_processes_extended_process_group_steps do |t|
      t.integer :decidim_participatory_process_group_id
      t.string :name
      t.string :description
      t.string :system_step_name
      t.date :start_date
      t.date :end_date
      
      t.timestamps
    end
  end
end
