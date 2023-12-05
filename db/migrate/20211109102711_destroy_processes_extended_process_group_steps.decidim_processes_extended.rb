# This migration comes from decidim_processes_extended (originally 20211109090122)
class DestroyProcessesExtendedProcessGroupSteps < ActiveRecord::Migration[5.2]
  def change
    drop_table :decidim_processes_extended_process_group_steps
  end
end
