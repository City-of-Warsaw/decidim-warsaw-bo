# This migration comes from decidim_projects (originally 20230530093957)
class AddShowStartVotingButtonDate < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :show_start_voting_button_at, :datetime

    reversible do |dir|
      dir.up do
        Decidim::ParticipatoryProcess.all.each do |process|
          process.update_column(:show_start_voting_button_at, process.paper_voting_submit_end_date)
        end
      end
    end
  end
end
