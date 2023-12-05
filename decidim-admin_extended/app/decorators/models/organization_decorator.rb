# frozen_string_literal: true

# OVERWRITTEN DECIDIM MODEL
# Model was expanded with:
# - has_one_attached association to attach image: image_mailer_header
# - validation for attached image
# - thumbnail for miniature added image

Decidim::Organization.class_eval do
  has_one_attached :image_mailer_header

  validate :acceptable_image_mailer_header
  
  def acceptable_image_mailer_header
    return unless image_mailer_header.attached?

    unless image_mailer_header.byte_size <= 50.megabyte
      errors.add(:image_mailer_header, "Maksymalny rozmiar pliku to 50MB")
    end

    acceptable_types = ["image/jpg", "image/jpeg", "image/gif", "image/png", "image/bmp", "image/ico"]
    unless acceptable_types.include?(image_mailer_header.content_type)
      errors.add(:image_mailer_header, "Dozwolne rozszerzenia plików: jpg jpeg gif png bmp ico")
    end
  end

  def thumbnail_150
    return unless image_mailer_header.attached?

    image_mailer_header.variant(resize: "150x150") if image_mailer_header.variable?
  end
end
