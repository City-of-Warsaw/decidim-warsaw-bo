# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a folder.
    class Admin::UpdateFolder < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(folder, form)
        @folder = folder
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

        update_folder
        broadcast(:ok, folder)
      end

      private

      attr_reader :form, :folder


      def update_folder
        @folder.update(folder_attributes)
      end

      def folder_attributes
        {
          name: @form.name
        }
      end    
    end
  end
end
