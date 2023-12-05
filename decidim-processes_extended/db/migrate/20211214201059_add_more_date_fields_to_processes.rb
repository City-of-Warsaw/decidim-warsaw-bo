class AddMoreDateFieldsToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :paper_project_submit_end_date, :date
    add_column :decidim_participatory_processes, :evaluation_cards_submit_end_date, :date
    add_column :decidim_participatory_processes, :paper_voting_submit_end_date, :date
    add_column :decidim_participatory_processes, :status_change_notifications_sending_end_date, :date
  end
end
