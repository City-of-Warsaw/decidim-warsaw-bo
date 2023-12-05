# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to send mails to remind authors about draft projects in current edition,
    # but only for online submitted, not for paper
    class RemindAboutDraftProjectsJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'remind_about_draft_project_template')

        # ID for actual edition component
        projects_component_id = Current.actual_edition.projects_component&.id
        drafts_from_edition = Decidim::Projects::Project.where(decidim_component_id: projects_component_id).where(is_paper: false).drafts
        uniq_authors = drafts_from_edition.map(&:creator_author).uniq
        uniq_authors.each do |author|
          next unless author
          next if author.email.blank?
          next unless valid_email?(author.email)

          ProjectMailer.remind_about_draft_project(mail_template, author).deliver_later
        end
      end
    end
  end
end
