# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to create and update Appeals.
    class WizardVoteDistrictProjectsForm < Decidim::Projects::WizardVoteForm
      validate :district_projects_count

      def district_projects_count
        errors.add(:district_projects, :district_projects_surpassed) if vote_validity_service.district_limits_surpassed?
      end
    end
  end
end
