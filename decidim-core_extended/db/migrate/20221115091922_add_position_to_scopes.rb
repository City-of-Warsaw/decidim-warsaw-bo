class AddPositionToScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :position, :integer, default: 0
  end
end
