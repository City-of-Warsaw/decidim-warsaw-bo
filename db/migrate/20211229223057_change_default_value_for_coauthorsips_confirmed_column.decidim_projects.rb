# This migration comes from decidim_projects (originally 20211229222513)
class ChangeDefaultValueForCoauthorsipsConfirmedColumn < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_coauthorships, :confirmed, from: true, to: false
  end
end
