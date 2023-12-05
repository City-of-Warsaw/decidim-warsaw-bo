# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a banned word.
    class Admin::CreateBannedWord < Rectify::Command
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

        create_banned_word
        update_black_list
        broadcast(:ok)
      end

      private

      attr_reader :form

      # private method
      #
      # creating banned word
      def create_banned_word
        BannedWord.create!(
          name: form.name
        )
      end

      # private method
      # updating Obscenity blackist file
      def update_black_list
        Obscenity::Base.blacklist = Decidim::AdminExtended::BannedWord.pluck(:name)
      end
    end
  end
end
