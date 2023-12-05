# frozen_string_literal: true

module Decidim
  # This class deals with uploading attachments to a participatory space.
  class SecureAttachmentUploader < AttachmentUploader

    # Decidimorg: /var/www/decidim/current/public/uploads/decidim/projects/endorsement/file
    # TEST: /var/www/decidim/storage/decidim_uploads/decidim/projects/endorsement
    # PROD:
    def store_dir
      if %w[development test].include?(Rails.env)
        "#{Rails.root.join('storage')}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      else
        "#{Rails.root.join('decidim_uploads')}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end

  end
end
