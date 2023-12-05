# frozen_string_literal: true

Decidim::UserGroup.class_eval do

  def public_name(with_number = false)
    name
  end
end