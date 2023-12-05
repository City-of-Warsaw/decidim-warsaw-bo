# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A form object to create and update Appeals in admin panel.
    class AppealForm < Decidim::Form
      include Decidim::AttachmentAttributes

      mimic :appeal

      attribute :appeal
      attribute :project_id, Integer
      attribute :time_of_submit, Decidim::Attributes::TimeWithZone
      attribute :body, String

      attachments_attribute :documents # Załaczniki
      attribute :remove_documents, [Integer]

      validates :body, presence: true
      validates :project_id, presence: true
      validates :time_of_submit, presence: true

      validate :notify_missing_attachment_if_errored

      # Public: sets Project
      def project
        @project ||= Decidim::Projects::Project.find_by(id: project_id)
      end

      # Public: maps appeal fields into FormObject attributes
      def map_model(model)
        super
        # The scope attribute is with different key (decidim_scope_id), so it
        # has to be manually mapped.
        self.appeal = model
        self.project_id = model.project.id if model.project
        self.add_documents = model.attachments if model.attachments.any?
        self.time_of_submit = model.time_of_submit
      end

      def rejected_projects
        Decidim::Projects::Project.where(decidim_component_id: current_component.id).waiting_for_appeal.order(esog_number: :asc)
      end

      private

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
