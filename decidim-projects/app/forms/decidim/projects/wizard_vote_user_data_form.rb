# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to create and update Appeals.
    class WizardVoteUserDataForm < Decidim::Projects::WizardVoteForm

      validates :first_name, :last_name, :pesel_number, :pesel_number_confirmation, presence: true
      validates :street, :street_number, :zip_code, :city, presence: true
      validates :pesel_number, pesel: true, if: proc { |attrs| attrs[:pesel_number].present? }
      validate :pesel_matches_confirmation
      validate :zip_code_has_proper_value

      def pesel_matches_confirmation
        return if pesel_number.blank? || pesel_number_confirmation.blank?

        errors.add(:pesel_number_confirmation, :pesels_do_not_match) if pesel_number != pesel_number_confirmation
      end

      def zip_code_has_proper_value
        return if zip_code.blank?

        errors.add(:zip_code, :wrong_zip_code) if vote_validity_service.wrong_zip_code?
      end

      # Public method used to set Organization TimeZone
      # Returns Organization
      def organization
        current_component.organization
      end
    end
  end
end
