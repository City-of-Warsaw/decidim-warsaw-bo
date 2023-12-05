# frozen_string_literal: true

Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell.class_eval do

  # Renders view for main page content block with
  # project tiles
  def show
    render :show_new
  end

  def highlighted_items
    Decidim::Projects::Project.implementation_on_main_site.order(updated_at: :desc).first(6)
  end

  def cache_hash
    hash = []
    hash << "decidim/content_blocks/highlighted-processes"
    hash << Digest::MD5.hexdigest(highlighted_items.pluck(:id).join(','))
    hash << Digest::MD5.hexdigest(Current.actual_edition.updated_at.to_s)
    hash.join("/")
  end
end
