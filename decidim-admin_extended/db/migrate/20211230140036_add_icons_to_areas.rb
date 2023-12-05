class AddIconsToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :icon, :string
  end
end
