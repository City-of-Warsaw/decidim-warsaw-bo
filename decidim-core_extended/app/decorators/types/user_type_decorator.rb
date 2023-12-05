# frozen_string_literal: true

Decidim::Core::UserType.class_eval do

  def name
    object.presenter.name
  end

end