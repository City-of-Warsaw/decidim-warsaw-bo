# frozen_string_literal: true

Decidim::VersionsListCell.class_eval do
  include Decidim::LayoutHelper

  def show
    render :show_new
  end
end
