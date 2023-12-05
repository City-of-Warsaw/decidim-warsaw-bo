# # frozen_string_literal: true

module Decidim
  module Projects::Admin
    module Implementation
      # A command with all the business logic when a user updates alternative description in implementation attachments.
      class UpdateAlt < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # proposal - the proposal to update.
        def initialize(form, project, current_user)
          @form = form
          @implementation_photo = form.model
          @project = project
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            handle_implementation
            update_alt
            add_log
          end

          broadcast(:ok, project)
        end

        private

        attr_reader :form, :project, :current_user

        def update_alt
          @implementation_photo.update_column('image_alt', form.alt)
        end

        def add_log
          @project = Decidim.traceability.perform_action!(
            :update_implementation,
            @project,
            @current_user,
            visibility: "admin-only"
          )
        end

        def handle_implementation
          Decidim::Projects::Implementation.create(implementation_attributes)
        end

        def implementation_attributes
          {
            # default
            project: @project,
            user: current_user,
            body: '',
            update_data: { photos_update: [["#{@implementation_photo.file.filename.to_s} [Aktualizacja opisu]", form.alt]] }
          }
        end
      end
    end
  end
end
