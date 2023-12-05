# This migration comes from decidim_core_extended (originally 20211113192200)
class AddYearToProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :edition_year, :integer, default: nil
  end
end
