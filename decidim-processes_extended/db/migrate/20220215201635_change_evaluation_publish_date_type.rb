class ChangeEvaluationPublishDateType < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_participatory_processes, :evaluation_publish_date, :datetime
  end
end
