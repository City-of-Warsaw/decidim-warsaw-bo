class AddOldIdsToScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :old_ids, :jsonb
  end
end
