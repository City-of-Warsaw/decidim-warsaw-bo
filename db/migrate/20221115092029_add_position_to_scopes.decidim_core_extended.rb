# This migration comes from decidim_core_extended (originally 20221115091922)
class AddPositionToScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :position, :integer, default: 0
  end
end
