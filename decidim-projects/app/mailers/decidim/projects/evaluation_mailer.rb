# frozen_string_literal: true

module Decidim
  module Projects
    # A custom mailer for sending notifications to users when
    # the events considering evaluations are received.
    class EvaluationMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      helper Decidim::ResourceHelper

      def notify(project, action, action_initiator, action_receiver)
        @project = project
        @project_path = decidim_projects.project_url(@project, host: @project.organization.host)
        @organization = project.organization
        @action = action
        @action_initiator = action_initiator
        @action_receiver = action_receiver
        @mail_scope = "decidim.events.projects.evaluation_mailer.#{action}"
        mail(to: @action_receiver.email, subject: I18n.t("decidim.events.projects.evaluation_mailer.#{action}.subject"))
      end

      def notify_with_template(project, action, action_initiator, action_receiver, additional_data = {})
        return if action_receiver.email.blank?
        return unless valid_email?(action_receiver.email)

        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: template_for_action(action))
        @body = parse_body(mail_template, project, action_initiator, action_receiver, additional_data)

        mail(to: action_receiver.email, subject: mail_template.subject, body: @body, content_type: "text/html")
      end

      private

      def parse_body(mail_template, project, action_initiator, action_receiver, additional_data)
        body = mail_template.body
        body = replace_project_data(body, project)
        body = replace_receiver_data(body, action_receiver)
        body = replace_organization_data(body, project.organization)
        body = replace_additional_data_data(body, additional_data)
        body = replace_current_role(body, action_initiator)
        body = replace_current_department(body, project.current_department)
        body
      end

      def replace_project_data(body, project)
        project_link = ::Decidim::ResourceLocatorPresenter.new(project).url
        body = body.gsub('%{project_title}', project.title)
                   .gsub('%{project_link}', project_link)
                   .gsub('%{edition_year}', project.edition_year.to_s)
        body
      end

      def replace_receiver_data(body, action_receiver)
        body = body.gsub('%{user_name}', action_receiver.public_name(true))
        body
      end

      def replace_current_department(body, current_department)
        return body if current_department.blank?

        body = body.gsub('%{current_department}', current_department&.name.presence || '') # for evaluation
        current_type = case current_department&.department_type
                       when "district" then 'dzielnicy'
                       when "district_unit" then 'jednostce'
                       when "general_municipal_unit" then 'jednostce'
                       when "office" then 'biurze'
                       else
                         ''
                       end
        body = body.gsub('%{current_type}', current_type.presence || '')
      end

      def replace_additional_data_data(body, additional_data)
        body
      end

      def replace_organization_data(body, organization)
        return body unless organization

        organization_link = decidim.root_url(host: organization.host)
        body.gsub('%{organization_name}', organization.name).gsub('%{organization_link}', organization_link)
      end

      def replace_current_role(body, action_initiator)
        role = action_initiator.ad_coordinator? ? 'Koordynator' : 'Podkoordynator'
        body.gsub('%{current_role}', role)
      end

      def template_for_action(action_name)
        case action_name
        when 'submit_for_formal' then 'project_assigned_for_formal_verification'
        when 'submit_for_meritorical' then 'project_assigned_for_meritorical_verification'
        when 'submit_appeal_for_verification' then 'project_assigned_for_reevaluation_verification'
        when 'change_verificator' then 'project_assigned_for_verification_email_template'
        else
          raise "Brak szablonu: #{action_name}"
        end
      end
    end
  end
end
