# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to the voting.
    class VoteJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(vote, email, action)
        return if email.blank?
        return unless valid_email?(email)

        case action
        when 'invitation_for_voting'
          VoteMailer.invitation_for_voting(vote).deliver_now
        when 'thank_you_for_voting'
          VoteMailer.thank_you_for_voting(vote).deliver_now
        end
      end
    end
  end
end
