class AddAgreementsFieldsToSimpleUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_simple_users, :show_my_name, :boolean, default: false
    add_column :decidim_projects_simple_users, :inform_me_about_proposal, :boolean, default: false
    add_column :decidim_projects_simple_users, :email_on_notification, :boolean, default: false
  end
end
