class AddIpNumberToVote < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :ip_number, :string
  end
end
