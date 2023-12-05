# frozen_string_literal: true

module Decidim
  module Projects::Admin::Evaluation
    # A command with all the business logic when a user creates a new formal evaluation.
    class CreateFormalEvaluation < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # project      - The project of the formal evaluation.
      def initialize(form, current_user, project)
        @form = form
        @project = project
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
        return broadcast(:invalid) unless project

        build_attachments
        return broadcast(:invalid) if attachments_invalid?

        transaction do
          create_formal_evaluation
          if process_attachments?
            build_evaluation_attachments("scan")
            create_attachments
          end
          # document_cleanup!
        end

        broadcast(:ok, @formal_evaluation)
      end

      private

      attr_reader :form, :project, :current_user, :formal_evaluation

      # Prevent PaperTrail from creating an additional version
      # in the formal_evaluation multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the formal_evaluation version control
      def create_formal_evaluation
        PaperTrail.request(enabled: false) do
          Decidim.traceability.perform_action!(
            :create_f_evaluation,
            project,
            @current_user,
            visibility: "admin-only"
          ) do
            @formal_evaluation = Decidim::Projects::FormalEvaluation.new(formal_evaluation_attributes)
            @formal_evaluation.save!
            @formal_evaluation
          end
        end
        @attached_to = @formal_evaluation
      end

      def formal_evaluation_attributes
        {
          project: @project,
          details: @form.attributes,
          user: current_user
        }
      end
    end
  end
end
