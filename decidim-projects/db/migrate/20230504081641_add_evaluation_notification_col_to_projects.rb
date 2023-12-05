class AddEvaluationNotificationColToProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_projects_projects, :notification_about_evaluation_results_send_by,
                  foreign_key: { to_table: :decidim_users },
                  index: { name: "index_projects_notif_eval_res_send_by_id" }
    add_column :decidim_projects_projects, :notification_about_evaluation_results_send_at, :datetime
  end
end
