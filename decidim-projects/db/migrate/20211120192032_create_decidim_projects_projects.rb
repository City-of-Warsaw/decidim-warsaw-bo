class CreateDecidimProjectsProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_projects do |t|
      t.string :title
      t.text :body
      t.string :state
      t.string :reference
      t.text :address
      t.float :latitude
      t.float :longitude
      t.datetime :published_at
      t.integer :coauthorships_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false
      t.text :justification_info
      t.text :localization_info
      t.integer :budget_value, default: 0
      t.string :endorsment_list
      t.integer :voting_number
      t.integer :esog_number
      t.boolean :is_paper, default: false
      t.text :short_description
      t.text :localization_additional_info
      t.text :availability_description
      t.boolean :universal_design
      t.text :universal_design_argumentation
      t.text :budget_description
      t.boolean :future_maintenance, default: nil
      t.text :future_maintenance_description
      t.decimal :future_maintenance_value, precision: 5, scale: 2
      t.text :negative_verification_reason
      t.text :project_implementation_effects
      t.text :producer_list
      t.text :remarks
      t.string :coauthor_email_one
      t.string :coauthor_email_two
      t.integer :edition_year
      t.string :admin_verification_status1
      t.string :admin_verification_status2

      t.references :decidim_scope, index: true
      t.references :component, foreign_key: { to_table: :decidim_components }, index: true
      t.references :evaluator, foreign_key: { to_table: :decidim_users }, index: true
      t.timestamps
    end
  end
end
