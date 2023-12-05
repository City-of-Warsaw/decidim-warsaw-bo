# frozen_string_literal: true

module Decidim
  module Projects
    # A custom mailer for sending notifications to users when
    # the events considering reevaluation are received.
    class ReevaluationMailer < Decidim::ApplicationMailer
      helper Decidim::ResourceHelper

      def notify(project, action, action_initiator, action_receiver)
        @project = project
        @project_path = decidim_projects.project_url(@project, host: @project.organization.host)
        @organization = project.organization
        @action = action
        @action_initiator = action_initiator
        @action_receiver = action_receiver
        @mail_scope = "decidim.events.projects.reevaluation_mailer.#{@action}"
        mail(to: @action_receiver.email, subject: I18n.t("decidim.events.projects.reevaluation_mailer.#{@action}.subject"))
      end

      # sends notification to coordinator from appeal.project.current_department about appeal draft finished by verifier
      def final_acceptance_admin_info(project, receiver)
        @organization = project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'final_acceptance_admin_info')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { project: project, user: receiver }).call

        mail(to: receiver.email, subject: mail_template.subject)
      end

      # notify coordinator that admin returns appeal to reverification
      def return_reevaluation_from_admin_to_coordinator(project, verifier, coordinator)
        @organization = project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'return_reevaluation_from_admin_to_coordinator')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { appeal: project.appeal,
                                                                                project: project,
                                                                                user: coordinator,
                                                                                verifier: verifier }).call

        mail(to: coordinator.email, subject: mail_template.subject)
      end

      # notify admins that coordinator accept reevaluation
      def accept_coordinator_reevaluation(project, user)
        @organization = project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'accept_coordinator_reevaluation')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { appeal: project.appeal,
                                                                                project: project,
                                                                                user: user }).call

        mail(to: user.email, subject: mail_template.subject)
      end

      # notify coordinator of appeal.project.current_department about appeal draft finished by verifier
      def finish_appeal_draft(appeal, coordinator)
        @organization = appeal.project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'finish_appeal_draft')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { appeal: appeal, project: appeal.project }).call

        mail(to: coordinator.email, subject: mail_template.subject)
      end

      # notify coordinator about finished reevaluation by verifier
      def finish_appeal_verification(project, verifier, coordinator)
        @organization = project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'finish_appeal_verification')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { appeal: project.appeal,
                                                                                project: project,
                                                                                user: coordinator,
                                                                                verifier: verifier }).call

        mail(to: coordinator.email, subject: mail_template.subject)
      end
    end
  end
end
