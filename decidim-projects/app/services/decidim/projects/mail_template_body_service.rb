# frozen_string_literal: true

module Decidim
  module Projects
    # Class parse mail_templates body for notifications
    class MailTemplateBodyService
      def initialize(mail_template, params = {})
        @mail_template = mail_template
        @body = @mail_template.body
        @params = params
      end

      def call
        appeal_variables_gsub
        project_variables_gsub
        user_variables_gsub
        verifier_variables_gsub
        vote_variables_gsub
        implementation_variables_gsub
        @body
      end

      private

      attr_reader :params

      def appeal_variables_gsub
        return unless params[:appeal]

        appeal = params[:appeal]
        project = appeal.project
        appeal_admin_url = admin_router(project.component).appeal_url(appeal)
        @body = @body.gsub('%{appeal_link}', appeal_admin_url)
      end

      def project_variables_gsub
        return unless params[:project]

        project = params[:project]
        project_admin_url = admin_router(project.component).project_url(project)
        @body = @body.gsub('%{project_title}', project.title)
                     .gsub('%{project_link}', project_admin_url)
                     .gsub('%{project_admin_url}', project_admin_url)
                     .gsub('%{project_public_link}', public_url_for_project(project))
                     .gsub('%{project_public_url}', public_url_for_project(project))
                     .gsub('%{edition_year}', project.edition_year.to_s)
                     .gsub('%{realization_year}', project.edition_year.to_s)

        reason_body = project.negative_evaluation_body
        @body = @body.gsub('%{reason_body}', reason_body) if reason_body.present?
      end

      def user_variables_gsub
        return unless params[:user]

        user = params[:user]
        @body = @body.gsub('%{user_name}', user.public_name(true))
      end

      def vote_variables_gsub
        return unless params[:vote]

        vote = params[:vote]
        results_step = vote.participatory_space.results_step
        voting_publication_time = results_step.end_date.presence || results_step.start_date.presence || vote.participatory_space.voting_step.end_date || results_step.end_date.presence

        @body = @body.gsub('%{voting_button}', button_for_vote_card(vote))
        @body = @body.gsub('%{voting_publication_time}', I18n.l(voting_publication_time, format: :year_with_month).to_s)
        @body = @body.gsub('%{voting_end_date}', I18n.l(vote.participatory_space.voting_step.end_date, format: :year_with_month).to_s)
        @body = @body.gsub('%{districts_projects}', districts_projects_template(vote.scope, vote.projects.in_district_scope))
        @body = @body.gsub('%{global_projects}', global_projects_template(vote.projects.in_global_scope))
        @body = @body.gsub('%{edition_year}', vote.participatory_space.edition_year.to_s)
      end

      def implementation_variables_gsub
        return unless params[:implementation]

        implementation = params[:implementation]
        project = implementation.project
        implementation_status = if project.implementation_status.zero?
                                  'Odstąpiono od realizacji'
                                elsif project.implementation_status == 5
                                  'Zakończono'
                                else
                                  'W trakcie'
                                end

        @body = @body.gsub('%{implementation_status}', implementation_status)
                     .gsub('%{implementation_body}', implementation.body)
      end

      def global_projects_template(global_projects)
        global_projects_string = '<p><strong>OGÓLNOMIEJSKIE</strong></p>'
        global_projects_string += '<p>'
        if global_projects.any?
          global_projects_string += '<ul>'
          global_projects.each do |proj|
            global_projects_string += '<li>' + public_link_to_project(proj) + '</li>'
          end
          global_projects_string += '</ul>'
        else
          global_projects_string += 'Brak wskazanych projektów ogólnomiejskich'
        end
        global_projects_string += '</p>'

        global_projects_string
      end

      def districts_projects_template(scope, district_projects)
        districts_projects_string = '<p><strong>DZIELNICOWE (' + (scope.nil? ? '-' : scope.name['pl']) + ')</strong></p>'
        districts_projects_string += '<p>'
        if district_projects.any?
          districts_projects_string += '<ul>'
          district_projects.each do |proj|
            districts_projects_string += '<li>' + public_link_to_project(proj) + '</li>'
          end
          districts_projects_string += '</ul>'
        else
          districts_projects_string += 'Brak wskazanych projektów dzielnicowych'
        end
        districts_projects_string += '</p>'

        districts_projects_string
      end

      def verifier_variables_gsub
        return unless params[:verifier]

        verifier = params[:verifier]
        @body = @body.gsub('%{verifier_name}', verifier.public_name(true))
      end

      def admin_router(component)
        @admin_router ||= Decidim::EngineRouter.admin_proxy(component) # route to admin!!
      end

      def public_url_for_project(project)
        host = project.organization.host
        Decidim::ResourceLocatorPresenter.new(project).url(host: host)
      end

      def public_link_to_project(project)
        ActionController::Base.helpers.link_to(project.title, public_url_for_project(project))
      end

      def button_for_vote_card(vote_card)
        url = Decidim::EngineRouter.main_proxy(vote_card.component).edit_votes_card_url(
          vote_card,
          link_sent: true,
          host: vote_card.organization.host
        )

        "<p style='padding: 25px 0px; text-align: center'>
        <a href='#{url}' class='button' style='font-weight: bold;font-size: 1.3rem'>ODDAJ GŁOS!</a>
        </p>"
      end
    end
  end
end
