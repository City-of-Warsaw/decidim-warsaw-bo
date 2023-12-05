# This migration comes from decidim_projects (originally 20220923130603)
class AddFollowsCountToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :follows_count, :integer, default: 0
  end
end
