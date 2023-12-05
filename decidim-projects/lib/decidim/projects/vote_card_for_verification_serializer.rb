# frozen_string_literal: true

module Decidim
  module Projects
    # This class serializes a Vote so can be exported to CSV, JSON or other
    # formats.
    class VoteCardForVerificationSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include Decidim::Projects::Admin::VotesCardsHelper

      # Public: Initializes the serializer with a vote.
      def initialize(vote_card, index = nil)
        @vote_card = vote_card
        @index = index
      end

      # Public: Exports a hash with the serialized data for this vote.
      def serialize
        {
          index: index,
          card_number: vote_card.card_number,
          submitting_method: vote_card.submitting_method,
          pesel_number: vote_card.pesel_number,
          status: vote_status(vote_card),
          email: vote_card.email,
          first_name: vote_card.first_name,
          last_name: vote_card.last_name,
          verified_first_name: verified_first_name,
          verified_last_name: verified_last_name,
          street: vote_card.street,
          street_number: vote_card.street_number,
          flat_number: vote_card.flat_number,
          zip_code: vote_card.zip_code,
          city: vote_card.city,
          scope: vote_card.scope ? translated_attribute(vote_card.scope.name) : nil,
          created_at: I18n.localize(vote_card.created_at, format: :decidim_short),
          updated_at: I18n.localize(vote_card.updated_at, format: :decidim_short),
          author: vote_card.author_name,
          ip_number: ip_number_info(vote_card)
        }
      end

      private

      attr_reader :vote_card, :index

      def component
        vote_card.component
      end

      def voter
        @voter ||= Decidim::Projects::Voter.find_by(pesel: vote_card.pesel_number&.downcase)
      end

      def verified_first_name
        return vote_card.first_name if vote_card.status == Decidim::Projects::VoteCard::STATUSES::VALID
        return if vote_card.status == Decidim::Projects::VoteCard::STATUSES::PESEL_NOT_VERIFIED

        voter.first_name if vote_card.status == Decidim::Projects::VoteCard::STATUSES::NAME_NOT_VERIFIED
      end

      def verified_last_name
        return vote_card.last_name if vote_card.status == Decidim::Projects::VoteCard::STATUSES::VALID
        return if vote_card.status == Decidim::Projects::VoteCard::STATUSES::PESEL_NOT_VERIFIED

        voter.last_name if vote_card.status == Decidim::Projects::VoteCard::STATUSES::NAME_NOT_VERIFIED
      end

    end
  end
end
