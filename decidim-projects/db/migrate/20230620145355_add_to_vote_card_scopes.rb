# frozen_string_literal: true

class AddToVoteCardScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :projects_in_global_scope, :json
    add_column :decidim_projects_vote_cards, :projects_in_districts_scope, :json
  end
end
