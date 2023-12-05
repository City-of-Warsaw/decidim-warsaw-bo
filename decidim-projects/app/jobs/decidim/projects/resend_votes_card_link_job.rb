# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to the voting.
    class ResendVotesCardLinkJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(votes_cards_ids, current_user)
        votes_cards(votes_cards_ids).each do |card|
          next if card.email.blank?
          next unless valid_email?(card.email)

          card.update(resend_email_date: Time.current,
                      resend_email_user: current_user,
                      resend_email_counter: card.resend_email_counter + 1)

           send_email_notification(card)
        end
      end

      private

      def votes_cards(votes_cards_ids)
        Decidim::Projects::VoteCard.where(id: votes_cards_ids)
      end

      def send_email_notification(vote_card)
        Decidim::Projects::VoteMailer.resend_invitation_for_voting(vote_card).deliver_later
      end
    end
  end
end
