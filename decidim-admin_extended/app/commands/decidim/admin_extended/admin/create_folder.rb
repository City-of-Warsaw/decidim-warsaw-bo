# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a folder.
    class Admin::CreateFolder < Rectify::Command
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

        create_folder
        broadcast(:ok)
      end

      private

      attr_reader :form, :folder

      # private method
      # creates folder
      def create_folder
        @folder = Folder.create(folder_attributes)
      end

      def folder_attributes
        {
          name: @form.name,
        }
      end    
    end
  end
end
