# # frozen_string_literal: true

module Decidim
  module Projects::Admin
    module Implementation
      # A command with all the business logic when a user updates an implementation.
      class UpdateImplementation < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # proposal - the proposal to update.
        def initialize(form, implementation, current_user)
          @form = form
          @implementation = implementation
          @original_status = implementation.project.implementation_status
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
            update_implementation
            notify_users if update_is_notifiable?
          end

          broadcast(:ok, implementation)
        end

        private

        attr_reader :form, :implementation, :current_user

        def update_implementation
          @implementation = Decidim.traceability.perform_action!(
            :update_implementation,
            implementation.project,
            current_user,
            visibility: "admin-only"
          ) do
            implementation.update(implementation_attributes)
            implementation
          end
        end


        def implementation_attributes
          {
            body: form.implementation_body,
            implementation_date: form.implementation_date
          }
        end

        # Private method checking if update provides data that should trigger notifications
        # - Implementation body is present OR
        # - Implementation status was changed
        #
        # Returns Boolean
        def update_is_notifiable?
          form.implementation_body.present? || form.implementation_status != @original_status
        end

        def notify_users
          Decidim::Projects::ImplementationMailerJob.perform_later(implementation)
        end
      end
    end
  end
end
