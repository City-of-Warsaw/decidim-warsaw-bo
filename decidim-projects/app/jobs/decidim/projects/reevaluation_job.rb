# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to reevaluation of the project.
    class ReevaluationJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(project, action, action_initiator, action_receiver)
        return unless action_receiver.inform_me_about_proposal
        return if action_receiver.email.blank?
        return unless valid_email?(action_receiver.email)

        ReevaluationMailer.notify(project, action, action_initiator, action_receiver).deliver_now
      end
    end
  end
end
