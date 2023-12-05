# frozen_string_literal: true

# OVERWITTEN DECIDIM UPLOADER
# This class deals with uploading hero images to ParticipatoryProcesses.
# Class was extended to support two additional image versions:
# default and square
Decidim::ImageUploader.class_eval do

  version :default do
    process resize_to_fit: [600, 180]
  end

  version :square do
    process resize_to_fit: [60, 60]
  end
end
