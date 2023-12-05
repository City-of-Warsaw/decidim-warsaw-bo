class AddIsPaperToAppeals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_appeals, :is_paper, :boolean, default: false
  end
end
