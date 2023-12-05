# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to the project.
    class NotifyProjectAuthorsJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(project_ids:, body:, subject: "Budżet obywatelski - wiadomość z portalu", sender_id: nil)
        projects(project_ids).each do |project|
          deliver_message_for(project, body, subject, sender_id)
        end
      end

      private

      # Private: fetch projects
      #
      # returns collection of projects
      def projects(project_ids)
        Decidim::Projects::Project.where(id: project_ids)
      end

      def deliver_message_for(project, body, subject, sender_id)
        sender = find_sender(sender_id)

        project.authors.each do |action_receiver|
          next unless action_receiver.inform_about_admin_changes
          next if action_receiver.email.blank?
          next unless valid_email?(action_receiver.email)

          ProjectMailer.notify(project, action_receiver, body, subject, sender).deliver_later
        end
      end

      def find_sender(sender_id)
        return unless sender_id

        Decidim::User.find(sender_id)
      end
    end
  end
end
