# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a recipient.
    class Admin::UpdateRecipient < Rectify::Command
      # Public: Initializes the command.
      #
      # recipient - Recipient object
      # form - A form object with the params.
      def initialize(recipient, form)
        @recipient = recipient
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_recipient
        broadcast(:ok)
      end

      private

      attr_reader :form

      # private method
      # updates recipient
      def update_recipient
        @recipient.update!(attributes)
      end

      # private method
      # maps recipient attributes provided by form
      # that can be updated
      def attributes
        {
          name: form.name,
          active: form.active
        }
      end
    end
  end
end
