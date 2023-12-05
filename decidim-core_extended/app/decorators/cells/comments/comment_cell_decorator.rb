# frozen_string_literal: true

Decidim::Comments::CommentCell.class_eval do
  include Decidim::Comments::Engine.routes.mounted_helpers

  def show
    render :show_new
  end
end
