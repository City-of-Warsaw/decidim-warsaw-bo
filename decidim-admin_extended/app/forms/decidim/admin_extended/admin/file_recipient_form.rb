# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update recipient.
      class FileRecipientForm < Form
        include Decidim::EmailChecker

        def initialize(row)
          @email = row["A"]
        end

        attribute :email, String
        validates :email, presence: true
        validate :check_email

        def check_email
          errors.add(:email, 'W podanym pliku wystąpiły niepoprawne adresy email') unless valid_email?(email)
        end
      end
    end
  end
end
