# frozen_string_literal: true

module Decidim
  module Projects
    # Validate vote_card before on last voting step - publish user's vote_card to system
    class WizardVoteCardPublishForm < Decidim::Projects::WizardVoteForm

      validates :first_name, :last_name, :pesel_number, :pesel_number_confirmation, presence: true
      validates :street, :street_number, :zip_code, :city, presence: true
      validates :pesel_number, pesel: true, if: proc { |attrs| attrs[:pesel_number].present? }
      validate :district_projects_count
      validate :global_projects_count
      validate :pesel_matches_confirmation
      validate :zip_code_has_proper_value

      def district_projects_count
        errors.add(:district_projects, :district_projects_surpassed) if vote_validity_service.district_limits_surpassed?
      end

      def global_projects_count
        errors.add(:global_projects, :global_projects_surpassed) if vote_validity_service.global_limits_surpassed?
      end

      def pesel_matches_confirmation
        return if pesel_number.blank? || pesel_number_confirmation.blank?

        errors.add(:pesel_number_confirmation, :pesels_do_not_match) if pesel_number != pesel_number_confirmation
      end

      def at_least_one_project_selected
        errors.add(:base, :no_projects_selected) if projects_in_global_scope.none? && projects_in_districts_scope.none?
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
