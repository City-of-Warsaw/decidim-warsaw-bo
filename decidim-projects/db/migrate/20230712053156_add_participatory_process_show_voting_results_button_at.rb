class AddParticipatoryProcessShowVotingResultsButtonAt < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :show_voting_results_button_at, :datetime

    reversible do |dir|
      dir.up do
        Decidim::ParticipatoryProcess.all.each do |process|
          process.update_column(:show_voting_results_button_at, DateTime.new(process.paper_voting_submit_end_date.year, 7, 15, 10, 10))
        end
      end
    end
  end
end
