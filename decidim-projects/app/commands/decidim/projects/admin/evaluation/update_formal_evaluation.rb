# frozen_string_literal: true

module Decidim
  module Projects::Admin::Evaluation
    # A command with all the business logic when a user updates formal evaluation.
    class UpdateFormalEvaluation < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # coauthorships - The coauthorships of the formal evaluation.
      def initialize(form, current_user)
        @form = form
        @formal_evaluation = form.formal_evaluation
        @project = @formal_evaluation.project
        @current_user = current_user
        @documents = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the formal evaluation.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless formal_evaluation

        build_attachments
        return broadcast(:invalid) if attachments_invalid?

        transaction do
          update_formal_evaluation
          update_formal_pdf
          if process_attachments?
            build_evaluation_attachments("scan")
            create_attachments
          end
          document_cleanup!
        end

        broadcast(:ok, @formal_evaluation)
      end

      private

      attr_reader :form, :project, :current_user, :formal_evaluation

      # Prevent PaperTrail from creating an additional version
      # in the formal evaluation multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the formal evaluation version control
      def update_formal_evaluation
        Decidim.traceability.perform_action!(
          :update_f_evaluation,
          project,
          @current_user,
          visibility: "admin-only"
        ) do
          formal_evaluation.update(formal_evaluation_attributes)
          update_project_evaluation
          formal_evaluation
        end
        @attached_to = formal_evaluation
      end

      def formal_evaluation_attributes
        {
          details: @form.attributes
        }
      end

      # Private: removing documents attached to evaluation
      #
      # returns nothing
      def document_cleanup!
        formal_evaluation.documents.where(id: @form.remove_documents).delete_all if @form.remove_documents.any?
      end

      # Private method that generates new card pdf file if it is necessary
      def update_formal_pdf
        # return if there was no file already
        attach = formal_evaluation.documents.where("file LIKE ?", '%dostepna%').last
        return unless attach

        # generate
        attach.destroy
        formal_evaluation.save_pdf_to_file
      end

      # aktualizuje status po edycji, zeby mozna bylo powtornie zatwierdzic ocene
      # np. w przypadku aktualizacji juz zamknietej oceny
      def update_project_evaluation
        project.update(state: 'published', verification_status: 'formal')
      end
    end
  end
end
