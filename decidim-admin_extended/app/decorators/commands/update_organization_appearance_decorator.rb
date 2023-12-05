# frozen_string_literal: true

# A command with all the business logic when updating an organization appearance.
Decidim::Admin::UpdateOrganizationAppearance.class_eval do

  private

  attr_reader :form, :organization

  # OVERWRITTEN DECIDIM METHOD
  def appearance_attributes
    {
      cta_button_path: form.cta_button_path,
      cta_button_text: form.cta_button_text,
      description: form.description,
      logo: form.logo,
      remove_logo: form.remove_logo,
      favicon: form.favicon,
      remove_favicon: form.remove_favicon,
      official_img_header: form.official_img_header,
      remove_official_img_header: form.remove_official_img_header,
      official_img_footer: form.official_img_footer,
      remove_official_img_footer: form.remove_official_img_footer,
      official_url: form.official_url,
      # added custom attributes:
      # image_mailer_header - allows adding images to admin/organization/appearance/edit
      # remove_image_mailer_header - allows removing images to admin/organization/appearance/edit
      # to update image of the mailer header
    }.tap do |hash|
       hash[:image_mailer_header] = form.image_mailer_header if form.image_mailer_header
       hash[:remove_image_mailer_header] = form.remove_image_mailer_header if form.remove_image_mailer_header
    end
  end
end
  