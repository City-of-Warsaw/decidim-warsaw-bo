# frozen_string_literal: true
module Decidim
  module AdminExtended
    # A command with all the business logic when updating a document.
    class Admin::UpdateDocument < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(document, form)
        @document = document
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

        update_document
        broadcast(:ok, document)
      end

      private

      attr_reader :form, :document

      # private method
      # updates document
      def update_document
        @document.update(document_attributes)
      end

      def document_attributes
        {
          folder_id: form.folder_id,
          coordinators: form.for_coordinators? || form.all_roles?,
          sub_coordinators: form.for_sub_coordinators? || form.all_roles?,
          verifiers: form.for_verifiers? || form.all_roles?,
          editors: form.for_editors? || form.all_roles?
        }.tap do |h|
          h[:file] = form.file if form.file.present?
        end
      end    
    end
  end
end
