# This migration comes from decidim_processes_extended (originally 20220215201635)
class ChangeEvaluationPublishDateType < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_participatory_processes, :evaluation_publish_date, :datetime
  end
end
