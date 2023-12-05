class UpdateFieldsForUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :user_name, :string
    add_column :decidim_users, :user_surname, :string
    add_column :decidim_users, :phone_number, :string
    # address
    add_column :decidim_users, :street, :string
    add_column :decidim_users, :street_number, :string
    add_column :decidim_users, :flat_number, :string
    add_column :decidim_users, :zip_code, :string
    add_column :decidim_users, :city, :string
    # anonimization
    add_column :decidim_users, :anonymous_number, :integer
    add_column :decidim_users, :show_my_name, :boolean, default: false
    add_column :decidim_users, :inform_me_about_proposal, :boolean, default: false
    # remove unused
    remove_column :decidim_users, :birth_year
    remove_column :decidim_users, :district
  end
end
