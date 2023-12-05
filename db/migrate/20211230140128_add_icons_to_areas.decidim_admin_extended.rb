# This migration comes from decidim_admin_extended (originally 20211230140036)
class AddIconsToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :icon, :string
  end
end
