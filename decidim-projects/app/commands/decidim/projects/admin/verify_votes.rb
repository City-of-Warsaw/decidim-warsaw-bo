# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic verifying votes.
    class VerifyVotes < Rectify::Command

      # Public: Initializes the command.
      #
      # component - component for finding votes in edition
      def initialize(component)
        @component = component
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when verifying is valid
      # - :invalid if we couldn't proceed.
      # - :no_voters if there is no imported voters in database
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless component
        return broadcast(:no_voters) if Decidim::Projects::Voter.none?

        transaction do
          verify_votes
        end

        broadcast(:ok)
      end

      private

      attr_reader :component

      # oll vote cards per projects edition (projects component)
      def vote_cards
        Decidim::Projects::VoteCard.where(component: component).submitted
      end

      # Private method updating vote_card status depending on:
      # - validity based on predefined elements
      # - founded voter by pesel and verified first_name and last_name
      def verify_votes
        all_accepted_votes = Decidim::Projects::VoteCard.where(component: component).accepted_votes
        list_of_used_pesels = all_accepted_votes.with_pesel.pluck(:pesel_number)

        vote_cards_count = vote_cards.count
        vote_cards_counter = 0

        vote_cards.find_each do |vote_card|
          vote_cards_counter += 1
          Rails.logger.info "Weryfikacja karty #{vote_cards_counter} z #{vote_cards_count} kart (#{vote_card.card_number})"
          next if vote_card.invalid?

          if Decidim::Projects::VoteCardValidityService.new(vote_card, list_of_used_pesels).invalid?
            vote_card.update_column(:status, Decidim::Projects::VoteCard::STATUSES::INVALID)
          else
            voter = Decidim::Projects::Voter.find_by(pesel: vote_card.pesel_number&.downcase)

            if vote_card.pesel_number.present? && voter
              if vote_card.first_name.present? && vote_card.last_name.present? &&
                  voter.first_name.downcase.strip == vote_card.first_name.downcase.strip &&
                  voter.last_name.downcase.strip == vote_card.last_name.downcase.strip
                vote_card.update_column(:status, Decidim::Projects::VoteCard::STATUSES::VALID)
              else
                vote_card.update_column(:status, Decidim::Projects::VoteCard::STATUSES::NAME_NOT_VERIFIED)
              end
            else
              vote_card.update_column(:status, Decidim::Projects::VoteCard::STATUSES::PESEL_NOT_VERIFIED)
            end
          end
        end
      end
    end
  end
end
