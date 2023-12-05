# frozen_string_literal: true

module Decidim
  module Projects
    # InternalDocument is a type of Attachment model.
    # It is used by Project. Can be only added in Admin Panel.
    class InternalDocument < Decidim::Attachment
      scope :visible, -> { where('decidim_attachments.temporary_file': false) }
      scope :temporary, -> { where('decidim_attachments.temporary_file': true) }

      self.inheritance_column = :attachment_type
      translatable_fields :title, :description
    end
  end
end
