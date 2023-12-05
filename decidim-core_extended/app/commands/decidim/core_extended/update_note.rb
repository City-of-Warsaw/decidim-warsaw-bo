# frozen_string_literal: true
module Decidim
  module CoreExtended
    # A command with all the business logic when a user updates a note.
    class UpdateNote < Rectify::Command

      def initialize(note, form, current_user)
        @note = note
        @form = form
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) if @form.invalid?

        update_note
        broadcast(:ok, note)
      end
      
      def update_note
        @note.update(note_attributes)
      end

      def note_attributes
        {
          title: @form.title,
          body: @form.body,
        }
      end
    end
  end
end