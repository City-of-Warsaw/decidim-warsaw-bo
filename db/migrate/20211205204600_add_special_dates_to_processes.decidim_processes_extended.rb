# This migration comes from decidim_processes_extended (originally 20211205201854)
class AddSpecialDatesToProcesses < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_participatory_processes, :evaluation_date
    remove_column :decidim_participatory_processes, :reevaluation_date
    remove_column :decidim_participatory_processes, :results_date
    remove_column :decidim_participatory_processes, :withdraw_date

    add_column :decidim_participatory_processes, :project_editing_end_date, :date
    add_column :decidim_participatory_processes, :withdrawn_end_date, :date
    add_column :decidim_participatory_processes, :evaluation_end_date, :date
    add_column :decidim_participatory_processes, :evaluation_publish_date, :date
    add_column :decidim_participatory_processes, :appeal_start_date, :date
    add_column :decidim_participatory_processes, :appeal_end_date, :date
    add_column :decidim_participatory_processes, :reevaluation_publish_date, :datetime
  end
end
