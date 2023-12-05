# frozen_string_literal: true

module Decidim::CoreExtended
  # A form object to update password for user in user profile.
  class UserPasswordForm < Decidim::Form
    mimic :user

    attribute :password, String

    validates :password, presence: true
    validates :password, confirmation: true, if: -> { password.present? }
    validates :password, password: { name: nil, email: nil, username: nil }, if: -> { password.present? }
  end
end
