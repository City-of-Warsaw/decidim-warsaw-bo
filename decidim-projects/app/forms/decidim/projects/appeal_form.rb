# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module Projects
    # A form object to create and update Appeals.
    class AppealForm < Decidim::Form
      include Decidim::AttachmentAttributes

      mimic :appeal

      attribute :project_id, Integer

      attribute :body, String
      attachments_attribute :documents # Załaczniki
      attribute :remove_documents, [Integer]

      validates :body, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }
      validate :notify_missing_attachment_if_errored
      validate :attachments_limit_reached?

      # Public: sets Project
      def project
        @project ||= current_user.projects.find_by(id: project_id)
      end

      def map_model(model)
        super

        # The scope attribute is with different key (decidim_scope_id), so it
        # has to be manually mapped.
        self.add_documents = model.attachments if model.attachments.any?
      end

      private

      # This method will add an error to the `attachment` fields only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.any?
      end

      def attachments_limit_reached?(max_files_num: 10)
        if add_documents.size > max_files_num
          errors.add(:add_documents, "Maksymalna liczba plików: #{max_files_num}")
        end
      end
    end
  end
end
