# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a contact info position.
    class Admin::CreateContactInfoPosition < Rectify::Command
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

        create_contact_info_position
        broadcast(:ok)
      end

      private

      attr_reader :form, :contact_info_position

      # Private method
      #
      # Creates contact info position
      def create_contact_info_position
        @contact_info_position = ContactInfoPosition.create(contact_info_position_attributes)
      end

      # Private: attributes of contact info position
      #
      # returns Hash
      def contact_info_position_attributes
        {
          name: form.name,
          position: form.position,
          phone: form.phone,
          email: form.email,
          published: form.published,
          weight: form.weight,
          contact_info_group_id: form.contact_info_group_id
        }
      end
    end
  end
end
