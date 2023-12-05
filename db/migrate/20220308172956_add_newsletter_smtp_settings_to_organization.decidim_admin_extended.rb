# This migration comes from decidim_admin_extended (originally 20220308172538)
class AddNewsletterSmtpSettingsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :newsletter_smtp_settings, :jsonb
  end
end
