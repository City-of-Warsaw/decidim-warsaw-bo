# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails that are using templates defined in admin panel.
    class TemplatedMailerJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(resource, action_receiver, mail_template, additional_data = {})
        # most of those emails MUST be sent
        # return unless action_receiver.email_on_notification
        return if action_receiver.email.blank?
        return unless valid_email?(action_receiver.email)

        ProjectMailer.notify_from_template(resource, action_receiver, mail_template, additional_data = additional_data).deliver_now
      end
    end
  end
end
