# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user creates a new appeal.
    class CreateAppeal < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user
      def initialize(form, current_user)
        @form = form
        @project = form.project
        @current_user = current_user
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed
      # - :invalid if there was no project
      # - :invalid if attachments are invalid
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless project

        build_attachments
        return broadcast(:invalid) if attachments_invalid?


        transaction do
          create_appeal
          create_attachments if process_attachments?
        end

        broadcast(:ok, @appeal)
      end

      private

      attr_reader :form, :project, :current_user

      # private method
      #
      # creating Appeal without versioning or ActionLog
      #
      # returns Appeal
      def create_appeal
        @appeal = Decidim::Projects::Appeal.create(appeal_attributes)

        @attached_to = @appeal
      end

      # private method
      #
      # returns Hash - mapped attributes for appeal
      def appeal_attributes
        {
          # default
          project: @project,
          body: form.body
        }
      end

      # private method
      #
      # returns Object - Organization from current_user
      def organization
        @organization ||= @current_user.organization
      end
    end
  end
end
