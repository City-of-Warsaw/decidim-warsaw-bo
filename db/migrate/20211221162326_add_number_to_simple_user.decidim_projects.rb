# This migration comes from decidim_projects (originally 20211221161413)
class AddNumberToSimpleUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_simple_users, :anonymous_number, :integer
  end
end
