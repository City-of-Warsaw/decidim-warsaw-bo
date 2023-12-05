# This migration comes from decidim_projects (originally 20221010061632)
class AddScopeToDrawingProjectsLogs < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_projects_drawing_projects_logs, :scope
  end
end
