# frozen_string_literal: true

Decidim::Admin::OrganizationAppearanceForm.class_eval do
  attribute :image_mailer_header
  attribute :remove_image_mailer_header

  validates :image_mailer_header, passthru: { to: Decidim::Organization }
end
