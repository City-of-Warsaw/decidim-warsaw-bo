# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to the voting.
    class ProjectVotingEndedJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(projects_component)
        projects_count = projects(projects_component).count

        projects(projects_component).each_with_index do |project, index|

          project.authors.each do |user|
            email = user.email
            next if email.blank?
            next unless valid_email?(email)

            if project.selected?
              ProjectMailer.winning_project(project, email).deliver_later
            elsif project.not_selected?
              ProjectMailer.loosing_project(project, email).deliver_later
            end

            project.update_column(:mail_delivered_at, DateTime.now) unless project.mail_delivered_at
          end
        end
      end

      def projects(projects_component)
        @projects ||= Decidim::Projects::ProjectsForVoting.new(projects_component).query
                                                          .where(mail_delivered_at: nil)
                                                          .order(id: :desc)
      end
    end
  end
end
