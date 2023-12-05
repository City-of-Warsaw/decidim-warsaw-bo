# This migration comes from decidim_processes_extended (originally 20230512144455)
class AddReevaluationDates < ActiveRecord::Migration[5.2]
  def change
    # until when verifiers can do reevaluation
    add_column :decidim_participatory_processes, :reevaluation_cards_submit_end_date, :date
    # by when coordinators can approve it
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
