# frozen_string_literal: true

module Decidim
  module Projects
    # A custom mailer for sending notifications to users when
    # the events considering projects are received.
    class VoteMailer < Decidim::ApplicationMailer
      include Decidim::ResourceHelper

      helper_method :url_for_project

      def invitation_for_voting(vote_card)
        @organization = vote_card.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'invitation_for_voting')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { vote: vote_card }).call

        mail(to: vote_card.email, subject: mail_template.subject)
      end

      def resend_invitation_for_voting(vote_card)
        @organization = vote_card.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'resend_invitation_for_voting')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { vote: vote_card }).call

        mail(to: vote_card.email, subject: mail_template.subject)
      end

      def thank_you_for_voting(vote_card)
        @organization = vote_card.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'thank_you_for_voting')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { vote: vote_card }).call

        mail(to: vote_card.email, subject: mail_template.subject)
      end

      private

      def url_for_project(project)
        host = project.organization.host
        resource_locator(project).url(host: host)
      end
    end
  end
end
