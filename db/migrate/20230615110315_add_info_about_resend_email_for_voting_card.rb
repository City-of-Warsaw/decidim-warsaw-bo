# frozen_string_literal: true

class AddInfoAboutResendEmailForVotingCard < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_vote_cards, :resend_email_date, :datetime, default: nil
    add_column :decidim_projects_vote_cards, :resend_email_user_id, :integer
    add_column :decidim_projects_vote_cards, :resend_email_counter, :integer, default: 0
    add_index :decidim_projects_vote_cards, :resend_email_user_id
  end
end
