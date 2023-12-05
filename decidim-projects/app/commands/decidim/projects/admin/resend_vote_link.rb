# frozen_string_literal: true

module Decidim
  module Projects
  module Admin
    # A command with all the business logic to resend invittion for voting.
    class ResendVoteLink < Rectify::Command
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
        return broadcast(:email_invalid) if @votes_card.email.blank?
        return broadcast(:email_invalid) unless valid_email?(@votes_card.email)

        Decidim.traceability.perform_action!(:resend_voting_email, @votes_card, current_user, visibility: "admin-only") do
          send_email_notification(@votes_card)
        end
        broadcast(:ok)
      end

      private

      attr_reader :votes_card, :current_user

      def send_email_notification(vote_card)

        Decidim::Projects::VoteMailer.invitation_for_voting(vote_card).deliver_later
      end
    end
  end
  end
end
