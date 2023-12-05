# This migration comes from decidim_projects (originally 20220830134401)
class RemoveTimeColumnsAndAddOneJsonbTimeField < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_statistics, :voting_timetable, :jsonb, default: {}

    reversible do |dir|
      dir.up do
        remove_columns :decidim_projects_vote_statistics,
                       :first_view_entering_time,
                       :second_view_entering_time,
                       :third_view_entering_time,
                       :fourth_view_entering_time,
                       :fifth_view_entering_time
      end

      dir.down do
        add_column :decidim_projects_vote_statistics, :first_view_entering_time, :datetime
        add_column :decidim_projects_vote_statistics, :second_view_entering_time, :datetime
        add_column :decidim_projects_vote_statistics, :third_view_entering_time, :datetime
        add_column :decidim_projects_vote_statistics, :fourth_view_entering_time, :datetime
        add_column :decidim_projects_vote_statistics, :fifth_view_entering_time, :datetime
      end
    end
  end
end
