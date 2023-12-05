# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a document.
    class Admin::CreateDocument < Rectify::Command
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

        create_document
        broadcast(:ok)
      end

      private

      attr_reader :form, :document

      # private method
      # creates document
      def create_document
        @document = Document.create(document_attributes)
      end

      def document_attributes
        {
          file: form.file,
          folder_id: form.folder_id,
          coordinators: form.for_coordinators? || form.all_roles?,
          sub_coordinators: form.for_sub_coordinators? || form.all_roles?,
          verifiers: form.for_verifiers? || form.all_roles?,
          editors: form.for_editors? || form.all_roles?
        }
      end
    end
  end
end
