# frozen_string_literal: true

module Decidim
  module Projects
    # Endorsment is a type of Attachment model.
    # It is used by Project
    class Endorsement < Decidim::Attachment
      scope :visible, -> { where('decidim_attachments.temporary_file': false) }
      scope :temporary, -> { where('decidim_attachments.temporary_file': true) }

      self.inheritance_column = :attachment_type
      translatable_fields :title, :description

      # overwritten AttachmentUploader
      mount_uploader :file, Decidim::SecureAttachmentUploader
    end
  end
end
