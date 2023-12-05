# frozen_string_literal: true

module Decidim
  module Projects
    # Module holds all the logic to verify vote data.
    # It is used in:
    #   Vote Model - for showing list of invalid reasons and warnings
    #   WizardVoteUserDataForm - for validation
    class ProjectsVotesDataPresenter; end < SimpleDelegator
  end
end
