# frozen_string_literal: true

module Decidim
  module UsersExtended
    # A form object used to handle user registrations
    class RegistrationForm < Form
      mimic :user

      attribute :name, String
      attribute :nickname, String
      attribute :email, String
      attribute :password, String
      attribute :password_confirmation, String
      attribute :newsletter, Boolean
      attribute :tos_agreement, Boolean
      attribute :current_locale, String
      # custom
      attribute :gender
      attribute :first_name
      attribute :last_name
      attribute :rodo

      # decidim validations
      validates :email, presence: true, 'valid_email_2/email': { disposable: true }
      validates :password, confirmation: true
      validates :tos_agreement, allow_nil: false, acceptance: true

      validate :email_unique_in_organization
      validate :nickname_unique_in_organization
      validate :no_pending_invitations_exist

      # custom validations
      validates :rodo, allow_nil: false, acceptance: true
      validates :password, presence: true
      validate :password_characters

      def newsletter_at
        return nil unless newsletter?

        Time.current
      end

      # custom methods
      def gender_for_select
        Decidim::User::GENDERS.map do |g|
          [
            I18n.t("gender.#{g}", scope: "decidim.users"),
            g
          ]
        end
      end

      def name
        "#{generate_random_number}"
      end

      def nickname
        "user-#{generate_random_number}".first(20)
      end

      def generate_random_number
        rand(Time.current.to_i)
      end

      private

      def email_unique_in_organization
        errors.add :email, :taken if User.no_active_invitation.find_by(email: email, organization: current_organization).present?
      end

      def nickname_unique_in_organization
        errors.add :nickname, :taken if User.no_active_invitation.find_by(nickname: nickname, organization: current_organization).present?
      end

      def no_pending_invitations_exist
        errors.add :base, I18n.t("devise.failure.invited") if User.has_pending_invitations?(current_organization.id, email)
      end

      def password_characters
        return unless password

        errors.add :password, 'Nie spełnia wymienionych warunków' unless proper_password(password)
      end

      def proper_password(pass)
        !!pass.match(/[a-z]/) && !!pass.match(/[A-Z]/) && !!pass.match(/[0-9]/) && !!pass.match(/[!@#$%^&*()_,<>';\\\]\[|":{}=\-\+\.?]/)
      end
    end
  end
end
