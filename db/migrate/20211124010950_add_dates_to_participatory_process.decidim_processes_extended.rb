# This migration comes from decidim_processes_extended (originally 20211124010459)
class AddDatesToParticipatoryProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :evaluation_date, :date
    add_column :decidim_participatory_processes, :reevaluation_date, :date
    add_column :decidim_participatory_processes, :results_date, :date
    add_column :decidim_participatory_processes, :withdraw_date, :date
  end
end
