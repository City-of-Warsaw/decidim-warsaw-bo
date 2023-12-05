# This migration comes from decidim_projects (originally 20211210210546)
class AddNoteToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :evaluation_note, :text
  end
end
