# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to implementation of the project.
    class ImplementationJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(project, action_receiver, body)
        return unless action_receiver.inform_me_about_proposal
        return if action_receiver.email.blank?
        return unless valid_email?(action_receiver.email)

        ProjectMailer.notify(project, action_receiver, body).deliver_now
      end
    end
  end
end
