# frozen_string_literal: true

module Decidim
  module Projects
    # A custom mailer for sending notifications to users when
    # the events considering projects are received.
    class ProjectMailer < Decidim::ApplicationMailer
      helper Decidim::ResourceHelper
      helper Decidim::Projects::SharedHelper
      helper Decidim::Projects::Admin::ProjectsHelper

      def winning_project(project, email)
        @organization = project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'result_voting_winning_project')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { project: project }).call

        mail(to: email, subject: mail_template.subject)
      end

      def loosing_project(project, email)
        @organization = project.organization
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'result_voting_loosing_project')
        @body = Decidim::Projects::MailTemplateBodyService.new(mail_template, { project: project }).call

        mail(to: email, subject: mail_template.subject)
      end

      def notify(project, action_receiver, body, subject = 'Budżet obywatelski - wiadomość z serwisu', sender = nil)
        @user = @action_receiver = action_receiver
        @sender = sender
        @project = project
        @organization = @user.organization
        @organization_link = decidim.root_url(host: @organization.host)
        @project_path = @project ? decidim_projects.project_url(@project, host: @organization.host) : @organization_link
        @body = project_variables_gsub(body, @project)
        @body = implementation_variables_gsub(@body, @project.implementations.last) if @project.implementations.any?
        # shared
        @body.gsub('%{user_name}', @user.public_name(true))
             .gsub('%{organization_name}', @organization.name)
             .gsub('%{organization_link}', @organization_link)

        mail(to: @user.email, subject: subject)
      end

      def notify_from_template(resource, action_receiver, mail_template, additional_data = {})
        @mail_template_body = mail_template.body
        @user = action_receiver
        @organization = @user.organization
        organization_link = decidim.root_url(host: @organization.host)
        @resource = resource
        @body = if resource.is_a?(Decidim::Projects::Project)
                  project_variables_gsub(@mail_template_body, resource)
                elsif resource.is_a?(Decidim::Comments::Comment)
                  comment_variables_gsub(@mail_template_body, resource)
                elsif resource.is_a?(Decidim::Projects::Appeal)
                  appeal_variables_gsub(@mail_template_body, resource, additional_data)
                elsif resource.is_a?(Decidim::Projects::Implementation)
                  implementation_variables_gsub(@mail_template_body, resource)
                elsif resource.is_a?(Decidim::User) || resource.is_a?(Decidim::Projects::SimpleUser)
                  user_variables_gsub(@mail_template_body, resource)
                end
        if resource.respond_to?(:implementations) && resource.implementations.any?
          @body = implementation_variables_gsub(@mail_template_body, resource.implementations.last)
        end
        # shared
        registration_link = decidim.edit_coauthorship_acceptance_url(@user, host: @organization.host)
        @body = @body.gsub('%{user_name}', @user.public_name(true))
                     .gsub('%{organization_name}', @organization.name)
                     .gsub('%{organization_link}', organization_link)
                     .gsub('%{registration_link}', registration_link)
                     .gsub('%{password_reset_link}', registration_link) # uzywamy nowej rejestracji a nie zmiany hasla
                     .gsub('%{sender_email}', (additional_data[:sender_email]).to_s)
                     .gsub('%{private_message_body}', (additional_data[:private_message_body]).to_s)

        additional_data[:attachments]&.each do |name, file|
          attachments[name] = file
        end

        mail(to: @user.email, subject: mail_template.subject)
      end

      def remind_about_draft_project(mail_template, user)
        @user = user
        @organization = @user.organization
        @body = new_body(mail_template, user: user)
        mail(to: @user.email, subject: mail_template.subject)
      end

      def notify_author_about_evaluation_result(mail_template, user, project)
        @user = user
        @organization = @user.organization
        @body = new_body(mail_template, user: user, project: project)
        mail(to: @user.email, subject: mail_template.subject)
      end

      def remind_about_missing_evaluations(user, projects)
        @user = user
        @organization = @user.organization
        @projects = projects
        subject = 'Budżet obywatelski - powiadomienie o brakach w ocenie poszczególnych projektów'
        mail(to: @user.email, subject: subject)
      end

      def project_variables_gsub(body, project)
        organization = project.organization
        project_url = ::Decidim::ResourceLocatorPresenter.new(project).url
        reason_body = project.negative_evaluation_body
        coauthorship_acceptance_link = "#{project_url}/coauthorship/edit"

        body = body.gsub('%{project_title}', project.title)
                   .gsub('%{current_department}', project.current_department&.name.presence || '') # for evaluation
                   .gsub('%{district_name}', (project.scope.present? ? project.scope.name['pl'] : "-")) # for evaluation
                   .gsub('%{evaluation_name}', 'oceny merytorycznej') # for evaluation
                   .gsub('%{project_link}', project_url)
                   .gsub('%{project_public_url}', project_url)
                   .gsub('%{edition_year}', project.edition_year.to_s)
                   .gsub('%{coauthorship_acceptance_link}', coauthorship_acceptance_link) # for Decidim::User coauthorship
        body = body.gsub('%{reason_body}', reason_body) if reason_body.present?

        # for evaluation
        body = body.gsub('%{verifier_name}', project.evaluator.public_name(true)) if project.evaluator

        body
      end

      def comment_variables_gsub(body, comment)
        project = comment.root_commentable
        organization = project.organization
        project_url = ::Decidim::ResourceLocatorPresenter.new(project).url
        comment_url = "#{project_url}?commentId=#{comment.id}#comment_#{comment.id}"
        terms_and_conditions_link = decidim.page_url('terms-and-conditions', host: organization.host)

        body = project_variables_gsub(body, project)
        body.gsub('%{comment_body}', comment.body['pl'])
            .gsub('%{comment_link}', comment_url)
            .gsub('%{terms_and_conditions_link}', terms_and_conditions_link)
      end

      def appeal_variables_gsub(body, appeal, additional_data = {})
        project = appeal.project
        appeal_url = "#{::Decidim::ResourceLocatorPresenter.new(project).url}/appeals/#{appeal.id}"
        appeal_body = additional_data[:appeal_body].presence || appeal.body
        body = project_variables_gsub(body, project)
        body.gsub('%{appeal_link}', appeal_url)
            .gsub('%{appeal_body}', appeal_body)
      end

      def implementation_variables_gsub(body, implementation)
        project = implementation.project
        implementation_status = if project.implementation_status.zero?
                                  'Odstąpiono od realizacji'
                                elsif project.implementation_status == 5
                                  'Zakończono'
                                else
                                  'W trakcie'
                                end

        body = project_variables_gsub(body, project)
        body.gsub('%{implementation_status}', implementation_status)
            .gsub('%{implementation_body}', implementation.body)
      end

      def user_variables_gsub(body, user)
        token = ''
        organization = user.organization
        activation_link = decidim.user_confirmation_url(confirmation_token: token, host: organization.host)
        registration_link = decidim.new_user_registration_url(host: organization.host)
        password_reset_link = decidim.edit_user_password_url(reset_password_token: token, host: @organization.host)

        body.gsub('%{registration_link}', registration_link)
            .gsub('%{activation_link}', activation_link)
            .gsub('%{password_reset_link}', password_reset_link)
      end

      private

      def new_body(mail_template, user: nil, project: nil)
        body = mail_template.body
        if project
          project_url = ::Decidim::ResourceLocatorPresenter.new(project).url
          body = body.gsub('%{project_title}', project.title)
                     .gsub('%{project_link}', project_url) # nie uzywajmy tego
                     .gsub('%{project_public_url}', project_url)
                     .gsub('%{edition_year}', project.edition_year.to_s)
          reason_body = project.negative_evaluation_body
          body = body.gsub('%{reason_body}', reason_body) if reason_body.present?
        end
        body = body.gsub('%{user_name}', user.public_name(true)) if user
        body
      end
    end
  end
end
