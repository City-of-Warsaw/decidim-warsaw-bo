class CreateDecidimProjectsVoters < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_voters do |t|
      t.string :first_name
      t.string :last_name
      t.string :pesel
      t.timestamps
    end
  end
end
