# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to the project.
    class NotifyAuthorsAboutEvaluationResultsJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      # sends notifications to projects authors by coordinators about evaluation result
      def perform(projects_component, user, project = nil, for_all_projects = false)
        projects = projects_from_edition(projects_component)

        # if notifications should be sent by admin, for all projects
        unless for_all_projects
          projects = projects.where(current_department: user.department).where(notification_about_evaluation_results_send_at: nil)
        end

        # if we want to send notification only for one project
        projects = projects.where(id: project.id) if project
        projects = projects.where(id: 28008)

        # positive evaluation
        positive_mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'positive_evaluation_email_template')
        accepted_projects = projects.accepted
        accepted_projects.each do |project|
          notify_all_authors(positive_mail_template, project, user)
        end

        # negative evaluation
        negative_mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'negative_evaluation_email_template')
        rejected_projects = projects.rejected
        rejected_projects.each do |project|
          notify_all_authors(negative_mail_template, project, user)
        end
      end

      private

      def projects_from_edition(projects_component)
        Decidim::Projects::ProjectsFromEdition.for(projects_component).published.where.not(current_department_id: nil)
      end

      def notify_all_authors(template, project, user)
        project.coauthorships.where(confirmation_status: 'confirmed').map(&:author).each do |coauthor|
          next if coauthor.email.blank?
          next unless valid_email?(coauthor.email)

          ProjectMailer.notify_author_about_evaluation_result(template, coauthor, project).deliver_later

          project.update_columns(
            notification_about_evaluation_results_send_at: DateTime.current,
            notification_about_evaluation_results_send_by_id: user.id
          )
        end
      end
    end
  end
end
