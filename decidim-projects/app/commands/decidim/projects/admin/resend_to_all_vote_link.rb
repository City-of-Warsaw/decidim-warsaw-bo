# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to resend invitation for voting.
      class ResendToAllVoteLink < Rectify::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # current_user - The current user
        # current_component - Projects component
        def initialize(votes_card, current_user)
          @votes_card = votes_card
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid
        #
        # Returns nothing.
        def call
          return broadcast(:empty_votes) if @votes_card.empty?

          Decidim::Projects::ResendVotesCardLinkJob.perform_later(@votes_card.pluck(:id), current_user)

          Decidim.traceability.perform_action!(:resend_all_voting_email, @votes_card.first, current_user, visibility: "admin-only")

          broadcast(:ok)
        end

        private

        attr_reader :votes_card, :current_user
      end
    end
  end
end
