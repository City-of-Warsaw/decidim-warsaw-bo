# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a contact info position.
    class Admin::UpdateContactInfoPosition < Rectify::Command
      # Public: Initializes the command.
      #
      # contact_info_position - A contact info position to update.
      # form                  - A form object with the params.
      def initialize(contact_info_position, form)
        @contact_info_position = contact_info_position
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

        update_contact_info_position
        broadcast(:ok, contact_info_position)
      end

      private

      attr_reader :form, :contact_info_position

      # Private method
      #
      # Updates contact info position
      def update_contact_info_position
        @contact_info_position.update(contact_info_position_attributes)
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
