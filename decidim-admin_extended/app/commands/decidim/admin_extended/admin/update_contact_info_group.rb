# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a contact info group.
    class Admin::UpdateContactInfoGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # contact_info_group - A contact info group to update.
      # form               - A form object with the params.
      def initialize(contact_info_group, form)
        @contact_info_group = contact_info_group
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

        update_contact_info_group
        broadcast(:ok, contact_info_group)
      end

      private

      attr_reader :form, :contact_info_group

      # Private method
      #
      # Updates contact info group
      def update_contact_info_group
        @contact_info_group.update(contact_info_group_attributes)
      end

      # Private: attributes of contact info group
      #
      # returns Hash
      def contact_info_group_attributes
        {
          name: form.name,
          subtitle: form.subtitle,
          published: form.published,
          weight: form.weight
        }
      end
    end
  end
end
