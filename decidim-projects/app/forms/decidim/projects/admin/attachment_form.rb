# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A form object to update Implementations attachments in admin panel.
    class AttachmentForm < Decidim::Form
      mimic :attachment

      attribute :project_id, Integer
      attribute :model
      attribute :alt, String

      validates :alt, presence: true

      # Public: sets Project
      def project
        @project ||= Decidim::Projects::Project.find_by(id: project_id)
      end

      def attachment
        model
      end

      # Public: maps attachment fields into FormObject attributes
      def map_model(model)
        super

        # The scope attribute is with different key (decidim_scope_id), so it
        # has to be manually mapped.
        self.model = model
        self.project_id = model.attached_to_id if model.attached_to
        self.alt = model.image_alt
      end
    end
  end
end
