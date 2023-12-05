# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module Projects
    # A form object to finish registration by invited users.
    class CoauthorRegistrationForm < Decidim::Form
      mimic :user

      attribute :name, String
      attribute :nickname, String
      attribute :email, String
      attribute :password, String
      attribute :password_confirmation, String
      attribute :newsletter, Boolean
      attribute :tos_agreement, Boolean
      attribute :current_locale, String

      validates :password, confirmation: true
      validates :password, password: { name: :name, email: :email, username: :nickname }
      validates :password_confirmation, presence: true

      attribute :gender
      attribute :first_name
      attribute :last_name

      attribute :acceptance
      attribute :rodo

      validates :rodo, allow_nil: false, acceptance: true
      validates :password, presence: true
      validate :password_characters

      def newsletter_at
        return nil unless newsletter?

        Time.current
      end

      def gender_for_select
        Decidim::User::GENDERS.map do |g|
          [
            I18n.t("gender.#{g}", scope: "decidim.users"),
            g
          ]
        end
      end

      private

      def password_characters
        return unless password

        errors.add(:password, 'Nie spełnia wymienionych warunków') unless correct_password(password)
      end

      def correct_password(pass)

        !!pass.match(/[a-z]/) && !!pass.match(/[A-Z]/) && !!pass.match(/[0-9]/) && !!pass.match(/[!@#$%^&*()_,<>';\\\]\[|":{}=\-\+\.?]/)
      end
    end
  end
end
