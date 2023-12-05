class AddPublicToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :active, :boolean, default: true
  end
end
