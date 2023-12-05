# This migration comes from decidim_projects (originally 20211216031913)
class AddOldIdsToScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :old_ids, :jsonb
  end
end
