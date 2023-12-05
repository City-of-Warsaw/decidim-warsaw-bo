class AddAcceptanceDateToCoauthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_coauthorships, :coauthorship_acceptance_date, :datetime
  end
end
