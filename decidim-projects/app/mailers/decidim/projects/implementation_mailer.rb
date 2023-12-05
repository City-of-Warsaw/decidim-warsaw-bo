# frozen_string_literal: true

module Decidim
  module Projects
    # A custom mailer for sending notifications to users when
    # the events considering projects are received.
    class ImplementationMailer < Decidim::ApplicationMailer
      include Decidim::ResourceHelper

      def status_changed_for_author(implementation, email)
        @organization = implementation.project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'implementation_status_changed_author_info_email_template')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template,
                                                               {
                                                                 project: implementation.project,
                                                                 implementation: implementation
                                                               }).call

        mail(to: email, subject: mail_template.subject)
      end

      def implementation_update_for_follower(project, email)
        @project = project
        @organization = project.organization
        @project_link = resource_locator(project).url(host: @organization.host)
        @edition_year = project.participatory_space.edition_year
        @email = email
        mail(to: email, subject: 'Aktualizacja stanu realizacji projektu z budżetu obywatelskiego')
      end
    end
  end
end
