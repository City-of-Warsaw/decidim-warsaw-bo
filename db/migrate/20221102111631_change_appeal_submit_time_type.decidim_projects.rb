# This migration comes from decidim_projects (originally 20221102111358)
class ChangeAppealSubmitTimeType < ActiveRecord::Migration[5.2]
  def up
    change_column :decidim_projects_appeals, :time_of_submit, :datetime
  end

  def down
    change_column :decidim_projects_appeals, :time_of_submit, :date
  end
end
