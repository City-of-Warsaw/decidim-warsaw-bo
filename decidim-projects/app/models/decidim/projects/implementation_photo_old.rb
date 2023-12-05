# frozen_string_literal: true

# Migration ImplementationPhoto to ActiveStorage
#
# Decidim::Attachment.where(attachment_type: 'Decidim::Projects::ImplementationPhoto').count
# Decidim::Attachment.where(attachment_type: 'Decidim::Projects::ImplementationPhoto').update_all(attachment_type: 'Decidim::Projects::ImplementationPhotoOld')

module Decidim
  module Projects
    # ImplementationPhoto is a type of Attachment model.
    # It is used by Implementation
    class ImplementationPhotoOld < Decidim::Attachment
      self.inheritance_column = :attachment_type
      translatable_fields :title, :description
    end
  end
end
