# This migration comes from decidim_projects (originally 20211202060236)
class AddFieldsToProjects < ActiveRecord::Migration[5.2]
  def change
    # brak wskazania poziomu
    add_column :decidim_projects_projects, :no_scope_selected, :boolean, default: nil
    # Autor podpisał wniosek
    add_column :decidim_projects_projects, :signed_by_author, :boolean, default: nil
  end
end
