# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a faq.
    class Admin::CreateFaq < Rectify::Command
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

        create_faq
        broadcast(:ok)
      end

      private

      attr_reader :form, :faq, :faq_group

      # Private method
      #
      # Creates faq
      def create_faq
        @faq = Faq.create(faq_attributes)
      end

      # Private: attributes of faq
      #
      # returns Hash
      def faq_attributes
        {
          title: form.title,
          content: form.content,
          published: form.published,
          weight: form.weight,
          faq_group_id: form.faq_group_id
        }
      end
    end
  end
end
