class AddEvaluationStartDateToProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :evaluation_start_date, :date
  end
end
