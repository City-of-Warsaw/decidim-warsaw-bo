class AddIndexOnVotersPesels < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_projects_voters, :pesel
  end
end
