# frozen_string_literal: true

module Decidim
  module Projects::Admin::Reevaluation
    # A command with all the business logic when a user updates reevaluation.
    class UpdateReevaluation < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # coauthorships - The coauthorships of the reevaluation.
      def initialize(form, current_user)
        @form = form
        @reevaluation = form.reevaluation
        @project = @reevaluation.project
        @current_user = current_user
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the reevaluation.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless reevaluation

        build_attachments
        return broadcast(:invalid) if attachments_invalid?

        transaction do
          update_reevaluation
          update_reevaluation_pdf
          if process_attachments?
            build_evaluation_attachments("scan")
            create_attachments
          end
          document_cleanup!
        end

        broadcast(:ok, @reevaluation)
      end

      private

      attr_reader :form, :project, :current_user, :reevaluation

      # Prevent PaperTrail from creating an additional version
      # in the reevaluation multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the reevaluation version control
      def update_reevaluation
        Decidim.traceability.perform_action!(
          :update_reevaluation,
          project,
          @current_user,
          visibility: "admin-only"
        ) do
          @reevaluation.update(reevaluation_attributes)
          @reevaluation
        end
        @attached_to = @reevaluation
      end

      # only admin can overwrite all attributes, so we merge them, to not loose any
      def reevaluation_attributes
        {
          details: @form.attributes
        }
      end

      # Private: removing documents attached to evaluation
      #
      # returns nothing
      def document_cleanup!
        @reevaluation.documents.where(id: @form.remove_documents).delete_all if @form.remove_documents.any?
      end

      # Private method that generates new card pdf file if it is necessary
      def update_reevaluation_pdf
        # return if there was no file already
        attach = reevaluation.documents.where("file LIKE ?", '%dostepna%').last
        return unless attach

        # generate
        attach.destroy
        reevaluation.save_pdf_to_file
      end
    end
  end
end
