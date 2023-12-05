# This migration comes from decidim_projects (originally 20220822144933)
class AddIpNumberToVote < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_votes, :ip_number, :string
  end
end
