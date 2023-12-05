class AddClearedDataColumnToVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :cleared_data, :boolean, default: false
  end
end
