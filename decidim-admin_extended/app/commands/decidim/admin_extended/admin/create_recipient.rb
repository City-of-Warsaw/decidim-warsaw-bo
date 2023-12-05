# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a recipient.
    class Admin::CreateRecipient < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        create_recipient
        broadcast(:ok)
      end

      private

      attr_reader :form

      # private method
      # creates recipient
      def create_recipient
        Recipient.create!(
          name: form.name,
          active: form.active
        )
      end
    end
  end
end
