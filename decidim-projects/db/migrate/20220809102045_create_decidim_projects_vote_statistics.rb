class CreateDecidimProjectsVoteStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_vote_statistics do |t|
      t.references :vote, foreign_key: { to_table: :decidim_projects_votes }, index: true
      t.integer :district_projects_views_count, default: 0
      t.integer :global_projects_views_count, default: 0

      t.boolean :categories_filters_for_district_projects, default: false
      t.boolean :recipients_filters_for_district_projects, default: false
      t.boolean :phrase_filters_for_district_projects, default: false

      t.boolean :categories_filters_for_global_projects, default: false
      t.boolean :recipients_filters_for_global_projects, default: false
      t.boolean :phrase_filters_for_global_projects, default: false

      t.datetime :first_view_entering_time
      t.datetime :second_view_entering_time
      t.datetime :third_view_entering_time
      t.datetime :fourth_view_entering_time
      t.datetime :fifth_view_entering_time

      t.datetime :finished_voting_time

      t.timestamps
    end
  end
end
