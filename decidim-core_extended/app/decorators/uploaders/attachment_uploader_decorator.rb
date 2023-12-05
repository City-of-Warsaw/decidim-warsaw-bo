# frozen_string_literal: true

Decidim::AttachmentUploader.class_eval do

  process :rotate, if: :image?
  process :strip_new

  def filename
    model.new_file_name.presence || super
  end

  # overwritten method
  # :migration context disable file's extensions allow list
  def extension_allowlist
    case upload_context
    when :migration
      nil
    when :admin
      Decidim.organization_settings(model).upload_allowed_file_extensions_admin
    else
      Decidim.organization_settings(model).upload_allowed_file_extensions
    end
  end

  # overwritten method
  # CarrierWave automatically calls this method and validates the content
  # type fo the temp file to match against any of these options.
  # :migration context disable file's content_type allow list
  def content_type_allowlist
    case upload_context
    when :migration
      nil
    when :admin
      Decidim.organization_settings(model).upload_allowed_content_types_admin
    else
      Decidim.organization_settings(model).upload_allowed_content_types
    end
  end

  protected

  def rotate
    manipulate! do |image|
      image.auto_orient
      image
    end
  end

  # Overwritten, original remove embedded information before rotation from auto_orient
  def strip
    return
  end

  # Strips out all embedded information from the image
  def strip_new
    return unless image?(self)

    manipulate! do |img|
      img.strip
      img
    end
  end
end