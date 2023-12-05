class CreateDecidimProjectsSimpleUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_simple_users do |t|
      t.references :organization, index: { name: "decidim_organization_unregistered_author_id" }

      t.string :email
      t.string :phone_number
      t.string :first_name
      t.string :last_name

      t.string :gender
      t.string :street
      t.string :street_number
      t.string :flat_number
      t.string :zip_code
      t.string :city

      t.timestamps
    end
  end
end
