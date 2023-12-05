# This migration comes from decidim_projects (originally 20230705123000)
class AddIndexOnVotersPesels < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_projects_voters, :pesel
  end
end
