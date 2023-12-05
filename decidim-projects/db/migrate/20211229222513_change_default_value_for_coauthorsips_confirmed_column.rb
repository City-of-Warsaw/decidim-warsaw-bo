class ChangeDefaultValueForCoauthorsipsConfirmedColumn < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_coauthorships, :confirmed, from: true, to: false
  end
end
