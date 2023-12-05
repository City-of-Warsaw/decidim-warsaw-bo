# This migration comes from decidim_projects (originally 20220317053759)
class AddCoauthorToDecidimCoauthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_coauthorships, :coauthor, :boolean, default: false
  end
end
