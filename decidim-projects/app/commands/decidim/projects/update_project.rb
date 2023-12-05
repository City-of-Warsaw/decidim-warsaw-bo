# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user updates a project.
    class UpdateProject < Rectify::Command
      include ::Decidim::AttachmentMethods
      include Decidim::Projects::CustomAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # project      - The project to update.
      def initialize(form, current_user, project)
        @form = form
        @current_user = current_user
        @project = project
        @attached_to = project
        # custom
        @with_attachments = form.respond_to?(:add_documents)
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the project.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # - :invalid if attachments are invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if invalid?

        remove_attachments(project)

        build_endorsements_for(nil)
        build_consents_for(nil)
        build_files_for(nil)
        # collecting erros from attachments
        endorsements_invalid?
        files_invalid?
        consents_invalid?
        return broadcast(:invalid) if @form.errors.any?

        transaction do
          if form.is_a?(ProjectWizardAuthorStepForm)
            # for wizard second step
            # - user data update
            # - coauthors fields
            update_coauthors_emails
            update_creator_data
            remove_not_existing_coauthors
            add_coauthors
          elsif @project.draft?
            # for wizard first step
            update_draft
          else
            # for normal update
            update_project
            update_creator_data
            remove_not_existing_coauthors
            add_coauthors
            send_notification
          end

          build_endorsements_for(project)
          build_files_for(project)
          build_consents_for(project)
        end

        broadcast(:ok, project)
      end

      private

      attr_reader :form, :project, :current_user, :attachment

      # Private: checking if form is valid and if it is editable by the current user
      #
      # returns Boolean
      def invalid?
        form.invalid? || !(project.editable_by?(current_user))
      end

      # Private: updating project draft
      #
      # Version is not created, ActionLog is added
      #
      # Returns Project
      def update_draft
        PaperTrail.request(enabled: false) do
          @project = Decidim.traceability.perform_action!(
            :user_draft,
            @project,
            current_user,
            visibility: "all"
          ) do
            @project.assign_attributes(attributes)
            @project.categories = form.assigned_categories
            @project.recipients = form.recipients
            @project.locations = form.locations_data
            @project.save
            @project
          end
        end
      end

      # Private: updating project draft
      #
      # Version is created, ActionLog is added
      #
      # Returns Project
      def update_project
        @project = Decidim.traceability.perform_action!(
          :user_update,
          @project,
          current_user,
          visibility: "all"
        ) do
          @project.assign_attributes(published_project_attributes)
          @project.categories = form.assigned_categories
          @project.recipients = form.recipients
          @project.locations = form.locations_data
          @project.set_visible_version
          @project.save
          @project
        end
      end

      # Private: updating project draft with coauthors data
      #
      # Version is not created, ActionLog is added,
      # Update is performed on second step of the wizard creator
      #
      # Returns Project
      def update_coauthors_emails
        @project = Decidim.traceability.perform_action!(
          :user_draft,
          @project,
          current_user,
          visibility: "all"
        ) do
          @project.assign_attributes(coauthors_attributes)
          @project.save
          @project
        end
      end

      # Private: mapping allowed params
      #
      # Merging project attributes from both wizadr steps,
      # removing scope data from params, as it can only be updated by Admin users
      #
      # returns hash with project attributes with coauthors
      def published_project_attributes
        # deleting all the params that can not be updated after publishing
        attributes.tap { attributes.delete(:scope) }.merge(coauthors_attributes)
      end

      # Private: updating project's creator data, skipping validations
      #
      # Update is performed on second step of the wizard creator
      #
      # Returns: is update successful
      def update_creator_data
        current_user.update_columns(
          email_on_notification: form.email_on_notification
        )
        @project.update_column(:author_data, {
          email: @current_user.email,
          first_name: form.first_name,
          last_name: form.last_name,
          gender: form.gender,
          phone_number: form.phone_number, # can be cleared
          street: form.street,
          street_number: form.street_number,
          flat_number: form.flat_number, # can be cleared
          zip_code: form.zip_code,
          city: form.city,
          # agreements
          show_author_name: ActiveModel::Type::Boolean.new.cast(form.show_author_name),
          inform_author_about_implementations: ActiveModel::Type::Boolean.new.cast(form.inform_author_about_implementations)
        })
      end

      # Private: project attributes
      #
      # Returns Hash
      def attributes
        {
          # default attributes
          title: form.title,
          body: form.body,
          # custom
          short_description: form.short_description,
          universal_design: form.universal_design.is_a?(Array) ? form.universal_design[1] : form.universal_design,
          universal_design_argumentation: form.universal_design_argumentation,
          justification_info: form.justification_info,
          localization_info: form.localization_info,
          localization_additional_info: form.localization_additional_info,
          budget_value: form.budget_value,
          scope: form.scope,
          custom_categories: form.custom_categories,
          custom_recipients: form.custom_recipients,
          additional_data: form.additional_data
        }
      end

      # Private: project coauthors' emails attributes
      #
      # Returns Hash
      def coauthors_attributes
        {
          coauthor_email_one: form.coauthor_email_one&.downcase,
          coauthor_email_two: form.coauthor_email_two&.downcase
        }
      end

      # private method
      #
      # returns Object - Organization of the current user
      def organization
        @organization ||= current_user.organization
      end

      # private method
      #
      # add coauthor for project if project has coauthors emails
      #
      # returns noting
      def add_coauthors
        if project.coauthor_email_one.present?
          ProjectAuthorsManager.new(project).create_coauthor(project.coauthor_email_one&.downcase)
        end

        if project.coauthor_email_two.present?
          ProjectAuthorsManager.new(project).create_coauthor(project.coauthor_email_two&.downcase)
        end
      end

      # private method
      #
      # remove coauthor from project if there is no coauthor email in it
      #
      # returns noting
      def remove_not_existing_coauthors
        project.coauthorships.with_coauthors.each do |coauthorship|
          next if coauthorship.author.email&.downcase.in? [project.coauthor_email_one&.downcase, project.coauthor_email_two&.downcase]

          coauthorship.destroy
        end
      end

      # Private: Sending notifications to users about updating project
      #
      # returns nothing
      def send_notification
        # for invited users
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'applicant_information_after_project_edit_email_template')
        project.coauthorships.already_invited.map(&:author).each do |user|
          Decidim::Projects::TemplatedMailerJob.perform_later(project, user, mail_template)
        end

        # invite new coauthors
        project.coauthorships.with_coauthors.for_invitation.each do |coauthorship|
          coauthor = coauthorship.author
          invite_coauthor(coauthor)
          coauthorship.mark_invited
        end
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
