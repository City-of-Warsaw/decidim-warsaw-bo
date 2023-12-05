# This migration comes from decidim_projects (originally 20211229224054)
class AddAcceptanceDateToCoauthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_coauthorships, :coauthorship_acceptance_date, :datetime
  end
end
