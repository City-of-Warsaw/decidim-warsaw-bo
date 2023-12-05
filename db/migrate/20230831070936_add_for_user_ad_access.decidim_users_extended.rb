# This migration comes from decidim_users_extended (originally 20230831070553)
class AddForUserAdAccess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users,:ad_access_deactivate_date,:datetime
  end
end
