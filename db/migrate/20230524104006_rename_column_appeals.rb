class RenameColumnAppeals < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_appeals, :evaluator_id, :author_id
  end
end
