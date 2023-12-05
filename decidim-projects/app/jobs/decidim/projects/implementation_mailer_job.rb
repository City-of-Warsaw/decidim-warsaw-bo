# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails that are using templates defined in admin panel for creator
    # and standard mail for followers
    class ImplementationMailerJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(implementation)
        notify_authors(implementation)

        notify_followers(implementation)
      end

      private

      def notify_authors(implementation)
        project = implementation.project

        if project.author_data['inform_author_about_implementations'] && project.author_data['email'].present?
          ImplementationMailer.status_changed_for_author(implementation, project.author_data['email']).deliver_now
        end
        if project.coauthor1_data['inform_author_about_implementations'] && project.coauthor1_data['email'].present?
          ImplementationMailer.status_changed_for_author(implementation, project.coauthor1_data['email']).deliver_now
        end
        if project.coauthor2_data['inform_author_about_implementations'] && project.coauthor2_data['email'].present?
          ImplementationMailer.status_changed_for_author(implementation, project.coauthor2_data['email']).deliver_now
        end
      end

      def notify_followers(implementation)
        project = implementation.project
        project.followers.each do |user|
          next if user.email.blank?
          next unless valid_email?(user.email)
          next unless user.respond_to?(:watched_implementations_updates)
          next if user.respond_to?(:watched_implementations_updates) && !user.watched_implementations_updates

          ImplementationMailer.implementation_update_for_follower(project, user.email).deliver_now
        end
      end
    end
  end
end
