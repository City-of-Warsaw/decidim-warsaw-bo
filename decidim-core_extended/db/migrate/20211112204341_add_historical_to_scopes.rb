class AddHistoricalToScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :historical, :boolean, default: false
    add_column :decidim_scope_types, :historical, :boolean, default: false
  end
end
