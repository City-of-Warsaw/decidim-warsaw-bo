class ChangeDatesInProcessesToDatetime < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_participatory_processes, :evaluation_end_date, :datetime
    change_column :decidim_participatory_processes, :evaluation_cards_submit_end_date, :datetime
    change_column :decidim_participatory_processes, :appeal_start_date, :datetime
    change_column :decidim_participatory_processes, :appeal_end_date, :datetime
  end
end
