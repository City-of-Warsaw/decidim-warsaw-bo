# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to update Normal User.
      class NormalUserUpdateForm < Form
        mimic :normal_user

        attribute :confirmed, Boolean # wirtualny atrybut do potwierdzania uzytkownika
        attribute :confirmed_at, String
        attribute :email, String
        attribute :name, String
        attribute :first_name, String
        attribute :last_name, String
        attribute :nickname, String
        attribute :password, String

        attribute :organization, Decidim::Organization
        attribute :invited_by, Decidim::User
        attribute :gender, String
        attribute :about, String
        attribute :email_on_notification
        attribute :allow_private_message
        attribute :inform_me_about_comments
        attribute :newsletter
        attribute :watched_implementations_updates
        attribute :inform_about_admin_changes

        validates :email, presence: true

        # public method
        # normalizes email
        def email
          super&.downcase
        end

        # public method
        # sets Organization
        def organization
          super || current_organization
        end
      end
    end
  end
end
