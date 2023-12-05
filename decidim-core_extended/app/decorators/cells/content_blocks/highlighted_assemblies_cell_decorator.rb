# frozen_string_literal: true

Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell.class_eval do
  include Decidim::CardHelper

  # Renders view for main page content block with
  # projects in slider
  def show
    render :show_new
  end

  def highlighted_items
    Decidim::Projects::Project.implementation_on_main_site_slider.order(updated_at: :desc).first(3)
  end

  def cache_hash
    hash = []
    hash << "decidim/content_blocks/highlighted-assemblies"
    hash << Digest::MD5.hexdigest(highlighted_items.pluck(:id).join(','))
    hash << Digest::MD5.hexdigest(Current.actual_edition.updated_at.to_s)
    hash.join("/")
  end
end
