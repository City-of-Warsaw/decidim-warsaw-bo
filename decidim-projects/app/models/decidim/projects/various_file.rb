# frozen_string_literal: true

module Decidim
  module Projects
    # VariousFile is a type of Attachment model.
    # It is used by Project.
    class VariousFile < Attachment
      scope :visible, -> { where('decidim_attachments.temporary_file': false) }
      scope :temporary, -> { where('decidim_attachments.temporary_file': true) }

      self.inheritance_column = :attachment_type
      translatable_fields :title, :description
    end
  end
end
