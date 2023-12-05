# frozen_string_literal: true

module Decidim
  module Projects::Admin::Evaluation
    # A command with all the business logic when a user updates meritorical evaluation.
    class UpdateMeritoricalEvaluation < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # coauthorships - The coauthorships of the meritorical evaluation.
      def initialize(form, current_user)
        @form = form
        @meritorical_evaluation = form.meritorical_evaluation
        @project = @meritorical_evaluation.project
        @current_user = current_user
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the meritorical evaluation.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless meritorical_evaluation

        build_attachments
        return broadcast(:invalid) if attachments_invalid?

        transaction do
          update_meritorical_evaluation
          update_meritorical_pdf
          if process_attachments?
            build_evaluation_attachments("scan")
            create_attachments
          end
          document_cleanup!
        end

        broadcast(:ok, meritorical_evaluation)
      end

      private

      attr_reader :form, :project, :current_user, :meritorical_evaluation

      # Prevent PaperTrail from creating an additional version
      # in the meritorical evaluation multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the meritorical evaluation version control
      def update_meritorical_evaluation
        Decidim.traceability.perform_action!(
          :update_m_evaluation,
          project,
          @current_user,
          visibility: "admin-only"
        ) do
          meritorical_evaluation.update(meritorical_evaluation_attributes)
          update_project_evaluation
          meritorical_evaluation
        end
        @attached_to = meritorical_evaluation
      end

      def meritorical_evaluation_attributes
        {
          details: @form.attributes
        }
      end

      # Private: removing documents attached to evaluation
      #
      # returns nothing
      def document_cleanup!
        meritorical_evaluation.documents.where(id: @form.remove_documents).delete_all if @form.remove_documents.any?
      end

      # Private method that generates new card pdf file if it is necessary
      def update_meritorical_pdf
        # return if there was no file already
        attach = meritorical_evaluation.documents.where("file LIKE ?", '%dostepna%').last
        return unless attach

        # generate
        attach.destroy
        meritorical_evaluation.save_pdf_to_file
      end

      # updates the status after editing, so that you can formal accept it once again.
      # e.g. when updating an already closed formal accepted
      def update_project_evaluation
        project.update(state: 'published', verification_status: 'meritorical')
      end
    end
  end
end
