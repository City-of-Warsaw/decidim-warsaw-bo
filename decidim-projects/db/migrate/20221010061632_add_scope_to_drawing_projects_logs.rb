class AddScopeToDrawingProjectsLogs < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_projects_drawing_projects_logs, :scope
  end
end
