class AddMailDeliveredAtToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :mail_delivered_at, :datetime
  end
end
