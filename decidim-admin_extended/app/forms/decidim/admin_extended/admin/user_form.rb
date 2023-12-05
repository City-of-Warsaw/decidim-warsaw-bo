# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update User.
      class UserForm < Form
        mimic :user

        attribute :email, String
        attribute :name, String
        attribute :first_name, String
        attribute :last_name, String
        attribute :nickname, String
        attribute :password, String
        attribute :invitation_instructions, String
        attribute :organization, Decidim::Organization
        attribute :invited_by, Decidim::User

        validates :email, :name, :organization, :invitation_instructions, presence: true
        validates :name, format: { with: /\A(?!.*[<>?%&\^*#@()\[\]=+:;"{}\\|])/ }
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

        # public method
        # sets usera that creates object
        def invited_by
          super || current_user
        end

        # public method
        # sets role
        #
        # returns nil
        def role
          nil
        end
      end
    end
  end
end
