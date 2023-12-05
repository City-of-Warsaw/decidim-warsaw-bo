# This migration comes from decidim_projects (originally 20220207180925)
class ChangeColumnTypeInImplementations < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :decidim_projects_implementations, :implementation_date, :datetime
      end

      dir.down do
        change_column :decidim_projects_implementations, :implementation_date, :date
      end
    end
  end
end
