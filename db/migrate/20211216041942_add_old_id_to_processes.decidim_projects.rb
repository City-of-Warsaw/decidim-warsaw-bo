# This migration comes from decidim_projects (originally 20211216041821)
class AddOldIdToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :old_id, :integer
  end
end
