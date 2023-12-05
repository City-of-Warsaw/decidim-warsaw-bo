# frozen_string_literal: true

Decidim::Comments::CommentFormCell.class_eval do
  def show
    render :show_new
  end
end