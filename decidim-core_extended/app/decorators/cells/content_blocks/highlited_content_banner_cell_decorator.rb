# frozen_string_literal: true

Decidim::ContentBlocks::HighlightedContentBannerCell.class_eval do

  # added only cause of WCAG
  def show
    return unless current_organization.highlighted_content_banner_enabled

    render :show_new
  end
end