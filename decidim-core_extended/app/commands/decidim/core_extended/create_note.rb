# frozen_string_literal: true
module Decidim
  module CoreExtended
    # A command with all the business logic when a user creates a note.
    class CreateNote < Rectify::Command

      def initialize(form, current_user)
        @form = form
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) if @form.invalid?

        create_note
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user, :note, :user_id

      def create_note
        @note = Decidim::CoreExtended::Note.create(note_attributes)
      end

      def note_attributes
        {
          title: @form.title,
          body: @form.body,
          user: @current_user
        }
      end    
    end
  end
end
