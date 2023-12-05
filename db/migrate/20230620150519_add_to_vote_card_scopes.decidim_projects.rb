# frozen_string_literal: true
# This migration comes from decidim_projects (originally 20230620145355)

class AddToVoteCardScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :projects_in_global_scope, :json
    add_column :decidim_projects_vote_cards, :projects_in_districts_scope, :json
  end
end
