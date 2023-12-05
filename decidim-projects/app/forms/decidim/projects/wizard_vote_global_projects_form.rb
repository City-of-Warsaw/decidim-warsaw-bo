# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to create and update Appeals.
    class WizardVoteGlobalProjectsForm < Decidim::Projects::WizardVoteForm
      validate :global_projects_count

      def global_projects_count
        errors.add(:global_projects, :global_projects_surpassed) if vote_validity_service.global_limits_surpassed?
      end
    end
  end
end
