# This migration comes from decidim_projects (originally 20220802192201)
class AddBublisherToVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :publisher_id, :integer
    add_column :decidim_projects_votes, :publication_time, :datetime
  end
end
