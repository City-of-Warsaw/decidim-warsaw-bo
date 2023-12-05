class AddReevaluationDates < ActiveRecord::Migration[5.2]
  def change
    # do kiedy weryfikatorzy moga robic ponowną ocenę
    add_column :decidim_participatory_processes, :reevaluation_cards_submit_end_date, :date
    # do kiedy koordynatorzy moga zatwierdzic ponowną ocenę
    add_column :decidim_participatory_processes, :reevaluation_end_date, :date

    reversible do |dir|
      dir.up do
        Decidim::ParticipatoryProcess.all.each do |process|
          process.update_column(:reevaluation_cards_submit_end_date, process.reevaluation_publish_date)
          process.update_column(:reevaluation_end_date, process.reevaluation_publish_date)
        end
      end
    end
  end
end
