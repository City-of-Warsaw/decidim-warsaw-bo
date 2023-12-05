# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when a user publishes a paper vote card.
    class PublishVoteCard < Rectify::Command

      # Public: Initializes the command.
      #
      # vote         - A vote object with the params.
      # current_user - The current user.
      def initialize(vote_card, current_user)
        @vote_card = vote_card
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the vote has not proper status
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless vote_card.status == Decidim::Projects::VoteCard::STATUSES::WAITING

        transaction do
          publish_vote_card
        end

        broadcast(:ok, @vote_card)
      end

      private

      attr_reader :vote_card, :current_user

      # Prevent PaperTrail from creating an additional version
      #
      # Creates ActionLog
      #
      # returns Vote
      def publish_vote_card
        PaperTrail.request(enabled: false) do
          @vote_card = Decidim.traceability.perform_action!(
            :publish,
            @vote_card,
            @current_user,
            visibility: "admin-only"
          ) do
            @vote_card.update_columns(vote_card_attributes)
            @vote_card
          end
        end
      end


      # Private: vote_card attributes
      #
      # returns Hash
      def vote_card_attributes
        {
          publisher_id: current_user.id,
          publication_time: DateTime.current,
          status: status_card(vote_card)
        }
      end

      def status_card(vote_card)
        if Decidim::Projects::VoteCardValidityService.new(vote_card).invalid?
          Decidim::Projects::VoteCard::STATUSES::INVALID
        else
          Decidim::Projects::VoteCard::STATUSES::SUBMITTED
        end
      end
    end
  end
end
