# frozen_string_literal: true

Decidim::FlagModalCell.class_eval do

  def show
    render :show_new
  end
end