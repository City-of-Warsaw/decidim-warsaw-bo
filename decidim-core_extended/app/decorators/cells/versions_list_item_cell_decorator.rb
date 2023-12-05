# frozen_string_literal: true

Decidim::VersionsListItemCell.class_eval do

  def show
    render :show_new
  end

end
