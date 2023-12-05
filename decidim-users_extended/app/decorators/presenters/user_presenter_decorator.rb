# frozen_string_literal: true

Decidim::UserPresenter.class_eval do
  def name
    __getobj__.public_name(false)
  end

  def has_tooltip?
    # show_my_name
    false
  end
end