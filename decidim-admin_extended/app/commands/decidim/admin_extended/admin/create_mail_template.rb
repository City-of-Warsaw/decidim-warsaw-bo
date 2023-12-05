# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a mail template.
    class Admin::CreateMailTemplate < Rectify::Command
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

        create_mail_template
        broadcast(:ok)
      end

      private

      attr_reader :form

      # private method
      # creates mail template
      def create_mail_template
        MailTemplate.create!(
          name: form.name,
          system_name: form.system_name,
          subject: form.subject,
          body: form.body
        )
      end
    end
  end
end
