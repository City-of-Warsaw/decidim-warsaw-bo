# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user withdraws a new project.
    class WithdrawProject < Rectify::Command
      # Public: Initializes the command.
      #
      # project      - The project to withdraw.
      # current_user - The current user.
      def initialize(project, current_user)
        @project = project
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the project.
      #
      # Returns nothing.
      def call
        # return broadcast(:error) if @project.invalid?

        transaction do
          change_project_state_to_withdrawn
          send_notification
        end

        broadcast(:ok, @project)
      end

      private

      # Private: withdrawing project
      #
      # Creates version and ActionLog
      #
      # returns Project
      def change_project_state_to_withdrawn
        @project.set_visible_version
        Decidim.traceability.perform_action!(
          "withdrawn",
          @project,
          @current_user,
          visibility: "all"
        ) do
          @project.update(
            state: "withdrawn"
          )
          @project.save!
          @project
        end
      end

      # Private: Sending notifications to users about withdrawing project
      #
      # returns nothing
      def send_notification
        author_notification
        coauthors_notification

        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'withdrawn_project_email_inner_users_template')
        return unless mail_template&.filled_in?

        verificator_notification(mail_template)
        coordinators_notification(mail_template)

        coordinators = @project.current_department&.coordinators
        evaluator = @project.evaluator
        if evaluator && !coordinators.include?(evaluator)
          # send to current evaluator if he exists
          Decidim::Projects::TemplatedMailerJob.perform_later(@project, @project.evaluator, mail_template)
        end
      end

      def author_notification
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'withdrawn_project_email_template')
        return unless mail_template&.filled_in?

        Decidim::Projects::ProjectMailer.notify_from_template(@project, @project.creator_author, mail_template).deliver_later
      end

      def coauthors_notification
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'withdrawn_project_email_coauthor_template')
        return unless mail_template&.filled_in?

        # send only to confirmed coauthors
        @project.confirmed_coauthors.each do |user|
          Decidim::Projects::ProjectMailer.notify_from_template(@project, user, mail_template).deliver_later
        end
      end

      def coordinators_notification(mail_template)
        # send only when formal evaluation started
        return if @project.verification_status.blank?
        return if @project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING

        coordinators = @project.current_department&.coordinators
        return if coordinators.none?

        coordinators.each do |user|
          Decidim::Projects::ProjectMailer.notify_from_template(@project, user, mail_template).deliver_later
        end
      end

      def verificator_notification(mail_template)
        # send only when formal evaluation started
        return if @project.verification_status.blank?
        return if @project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING
        return unless @project.evaluator

        Decidim::Projects::ProjectMailer.notify_from_template(@project, @project.evaluator, mail_template).deliver_later
      end
    end
  end
end
