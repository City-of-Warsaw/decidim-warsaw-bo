# This migration comes from decidim_projects (originally 20230403063506)
class RenameDecidimProjectsVoteIdToVoteCard < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_project_votes, :decidim_projects_vote_id, :decidim_projects_vote_card_id
    rename_column :decidim_projects_vote_statistics, :vote_id, :vote_card_id
  end
end
