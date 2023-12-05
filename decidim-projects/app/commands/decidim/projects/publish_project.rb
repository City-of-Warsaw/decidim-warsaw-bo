# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user publishes a draft project.
    class PublishProject < Rectify::Command
      # Public: Initializes the command.
      #
      # project      - The project to publish.
      # form         - FOrm object with project data.
      # current_user - The current user.
      def initialize(project, form, current_user)
        @form = form
        @project = project
        @current_user = current_user
        @edition_year = @project.participatory_space.edition_year
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the project is published.
      # - :invalid if form is invalid.
      # - :invalid if the project's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless @project.authored_by?(@current_user)

        transaction do
          publish_project
          send_notifications
          # send_notification_to_participatory_space
        end

        broadcast(:ok, @project)
      end

      private

      attr_reader :form, :project, :current_user, :edition_year

      # Public method
      #
      # publishing project without versioning
      # adding ActionLog
      #
      # returns Project
      def publish_project
        Decidim.traceability.perform_action!(
          "user_publish",
          @project,
          @current_user,
          visibility: "all"
        ) do
          @project.update(
            published_at: Time.current,
            esog_number: Project.generate_esog(@project.participatory_space),
            edition_year: edition_year,
            current_department: scope_department,
            state: Decidim::Projects::Project::POSSIBLE_STATES::PUBLISHED,
            verification_status: Decidim::Projects::Project::VERIFICATION_STATES::WAITING
          )
          @project.department_assignments.create(department: scope_department) if scope_department
          add_coauthors
          @project.save!
          @project
        end
      end

      # private method
      #
      # returns Object - Department based on the Scoped of the Project
      def scope_department
        @project.scope.department
      end

      # private method
      #
      # returns Object - Organization of the Project
      def organization
        @organization ||= @project.organization
      end

      # private method
      #
      # add coauthor for project if project has coauthors emails
      #
      # returns noting
      def add_coauthors
        ProjectAuthorsManager.new(project).create_coauthor(project.coauthor_email_one) if project.coauthor_email_one.present?
        ProjectAuthorsManager.new(project).create_coauthor(project.coauthor_email_two) if project.coauthor_email_two.present?
      end

      # private method
      #
      # Sending notifications to users about publication of the project
      #
      # returns nothing
      def send_notifications
        # notification for author
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'project_published_email_template')
        Decidim::Projects::TemplatedMailerJob.perform_later(@project, current_user, mail_template)

        # notifications for coauthors
        project.coauthors.each { |coauthor| invite_coauthor(coauthor) }
      end

      # private method
      #
      # Sending notifications to users about them being invited to coauthor project
      #
      # returns nothing
      def invite_coauthor(user)
        mail_template = if user.sign_in_count.zero?
                          # user that was created by system
                          Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthor_invitation_email_template')
                        else
                          Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthorship_confirmation_email_template')
                        end
        Decidim::Projects::TemplatedMailerJob.perform_later(@project, user, mail_template)
      end
    end
  end
end
