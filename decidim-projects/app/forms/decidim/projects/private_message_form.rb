# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module Projects
    # A form object to create private message to the user.
    class PrivateMessageForm < Decidim::Form
      include Decidim::AttachmentAttributes

      attribute :project_id, Integer

      attribute :body, String
      attribute :email, String
      attachments_attribute :documents # Załaczniki
      attribute :remove_documents, [Integer]

      validates :body, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }
      validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

      # Public: fetch project
      #
      # returns object - Project
      def project
        @project ||= Decidim::Projects::Project.find_by(id: project_id)
      end

      # Public: mapping model
      #
      # we not mimicking models
      def map_model(model)
        super
      end

      private

      # Private method
      #
      # This method will add an error to the `attachment` fields only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.any?
      end
    end
  end
end
