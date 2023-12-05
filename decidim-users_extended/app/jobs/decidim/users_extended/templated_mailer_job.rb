# frozen_string_literal: true

module Decidim
  module UsersExtended
    class TemplatedMailerJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(user, mail_template, token=nil)
        # all of those emails MUST be sent
        # return unless action_receiver.email_on_notification
        return if user.email.blank?
        return unless valid_email?(user.email)

        Decidim::UsersExtended::ApplicationMailer.notify_from_template(user, mail_template, token).deliver_now
      end
    end
  end
end
