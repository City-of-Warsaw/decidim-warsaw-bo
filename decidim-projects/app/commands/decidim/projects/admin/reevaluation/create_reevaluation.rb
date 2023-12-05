# frozen_string_literal: true

module Decidim
  module Projects::Admin::Reevaluation
    # A command with all the business logic when a user creates a new reevaluation.
    class CreateReevaluation < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      def initialize(form, current_user, project)
        @form = form
        @project = project
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
        return broadcast(:invalid) unless project

        build_attachments
        return broadcast(:invalid) if attachments_invalid?


        transaction do
          create_reevaluation
          create_attachments if process_attachments?
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
      def create_reevaluation
        PaperTrail.request(enabled: false) do
          Decidim.traceability.perform_action!(
            :create_reevaluation,
            project,
            @current_user,
            visibility: "admin-only"
          ) do
            @reevaluation = Decidim::Projects::ReevaluationEvaluation.new(
              reevaluation_attributes
            )
            @reevaluation.save!
            @reevaluation
          end
        end
        @attached_to = @reevaluation
      end

      def reevaluation_attributes
        {
          project: @project,
          details: @form.attributes,
          user: current_user
        }
      end
    end
  end
end
