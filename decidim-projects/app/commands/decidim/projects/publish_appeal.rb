# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user publishes a draft appeal.
    class PublishAppeal < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form           - Form object with appeal data
      # appeal         - The appeal to publish.
      # current_user   - The current user.
      # skip_documents - Boolean for determining if documents should be processed
      def initialize(form, appeal, current_user, skip_documents = false)
        @form = form
        @appeal = appeal
        @project = appeal.project.presence || @form.project
        @current_user = current_user
        @attached_to = appeal
        @documents = []
        @skip_documents = skip_documents
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the appeal is published, together with the appeal.
      # - :invalid if attachments are invalid
      #
      # Returns nothing.
      def call
        build_attachments if process_attachments?
        return broadcast(:invalid) if attachments_invalid?

        transaction do
          publish_appeal
          create_attachments if process_attachments?
          document_cleanup!
          project_verification_status_update
          send_notifications
          # send_notification_to_participatory_space
        end

        broadcast(:ok, appeal)
      end

      private

      attr_reader :form, :appeal, :current_user, :project

      # private method
      #
      # publishing Appeal without versioning
      # with ActionLog
      #
      # returns Appeal
      def publish_appeal
        PaperTrail.request(enabled: false) do
          @appeal = Decidim.traceability.perform_action!(
            :user_publish_appeal,
            @project,
            current_user,
            visibility: "admin-only"
          ) do
            @appeal.update(
              body: form.body,
              time_of_submit: Time.current,
            )
            @appeal
          end
        end
      end

      # private method
      #
      # updateing verification status on project
      # to indicate there was submitted an appeal
      #
      # returns Project
      def project_verification_status_update
        project.update(verification_status: Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING)
      end

      # private method
      #
      # Sending notifications to proper users
      #
      # returns nothing
      def send_notifications
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'appeal_submitted_author_info_email_template')
        if mail_template&.filled_in?
          project.authors.each do |user|
            Decidim::Projects::TemplatedMailerJob.perform_later(appeal, user, mail_template, appeal_body: form.body)
          end
        else
          # old mail
          project.authors.each do |user|
            unless project.created_by?(user)
              Decidim::Projects::ReevaluationJob.perform_later(appeal, "publish_appeal_for_coauthor", current_user, user)
            end
          end
        end

        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'appeal_submited_admin_info_email_template')
        if mail_template&.filled_in?
          coordinators = project.current_department&.coordinators
          if coordinators&.any?
            coordinators.each do |user|
              # Send to all coordinators in current department
              Decidim::Projects::TemplatedMailerJob.perform_later(appeal, user, mail_template, appeal_body: form.body)
            end
          end

          sub_coordinators = project.users.sub_coordinators
          if sub_coordinators&.any?
            sub_coordinators.each do |user|
              # Send to all assigned sub_oordinators
              Decidim::Projects::TemplatedMailerJob.perform_later(appeal, user, mail_template, appeal_body: form.body)
            end
          end

          evaluators = project.users.verificators
          if evaluators&.any?
            evaluators.each do |user|
              # Send to all assigned evaluators
              Decidim::Projects::TemplatedMailerJob.perform_later(appeal, user, mail_template, appeal_body: form.body)
            end
          end
        end
      end

      # private method
      #
      # removing documents attached to Appeal
      #
      # returns nothing
      def document_cleanup!
        @appeal.documents.where(id: @form.remove_documents).delete_all if @form.remove_documents.any?
      end

      # private method
      #
      # adding documents attached to Appeal
      #
      # returns nothing
      def process_attachments?
        # if we in publish action, we want to skip processing attachemnts, otherwise it depends on the form contents
        @skip_documents ? false : @form.add_documents.any?
      end
    end
  end
end
