class AddBublisherToVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :publisher_id, :integer
    add_column :decidim_projects_votes, :publication_time, :datetime
  end
end
