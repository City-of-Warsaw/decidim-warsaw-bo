# frozen_string_literal: true

Decidim::ContentBlocks::LastActivityCell.class_eval do
  include Rails.application.routes.mounted_helpers

  def show
    render :show_new
  end

  private

  def last_editions
    Decidim::ParticipatoryProcess.where.not(published_at: nil)
                                 .where('show_voting_results_button_at <= ?', DateTime.current)
                                 .order(edition_year: :desc)
  end

  def cache_hash
    hash = []
    hash << "decidim/content_blocks/last_activity"
    hash << Digest::MD5.hexdigest(last_editions.map(&:cache_key_with_version).to_s)
    hash << I18n.locale.to_s

    hash.join("/")
  end
end

