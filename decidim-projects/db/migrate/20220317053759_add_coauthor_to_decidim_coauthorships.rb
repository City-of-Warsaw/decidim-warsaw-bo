class AddCoauthorToDecidimCoauthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_coauthorships, :coauthor, :boolean, default: false
  end
end
