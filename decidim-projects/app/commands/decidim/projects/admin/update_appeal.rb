# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when a user updates a appeal.
    class UpdateAppeal < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # appeal       - the appeal to update.
      def initialize(form, current_user, appeal)
        @form = form
        @current_user = current_user
        @appeal = appeal
        @attached_to = appeal
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # - :invalid if the attachments are invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        build_attachments
        return broadcast(:invalid) if attachments_invalid?

        transaction do
          update_appeal
          create_attachments if process_attachments?
          document_cleanup!
        end

        broadcast(:ok, appeal)
      end

      private

      attr_reader :form, :appeal, :current_user

      # Private: update appeal
      #
      # returns Appeal
      def update_appeal
        PaperTrail.request(enabled: false) do
          @appeal = Decidim.traceability.perform_action!(
            :update_appeal,
            @appeal.project,
            current_user,
            visibility: "admin-only"
          ) do
            @appeal.assign_attributes(attributes)
            @appeal.save
            @appeal
          end
        end
        @attached_to = @appeal
      end

      # Private: appeal attirbutes
      #
      # returns Hash
      def attributes
        {
          body: form.body,
          time_of_submit: form.time_of_submit,
        }
      end

      # Private: removing documents attached to Appeal
      #
      # returns nothing
      def document_cleanup!
        @appeal.documents.where(id: @form.remove_documents).delete_all if @form.remove_documents.any?
      end
    end
  end
end
