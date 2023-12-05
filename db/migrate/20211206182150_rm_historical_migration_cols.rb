class RmHistoricalMigrationCols < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_scopes, :historical
    remove_column :decidim_scope_types, :historical
  end
end
