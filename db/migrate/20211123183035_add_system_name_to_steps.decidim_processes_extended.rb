# This migration comes from decidim_processes_extended (originally 20211123182911)
class AddSystemNameToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :system_name, :string
  end
end
