# This migration comes from decidim_admin_extended (originally 20230713112405)
class CreateNewsletterRecipientsFromFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_newsletter_recipients_from_files do |t|
      t.string :email
      t.string :name
      t.datetime :sent_at
      t.references :newsletter, null: false, index: { name: "decidim_admin_newsletter_recipients_newsletter_id" }
      t.references :organization, null: false, index: { name: "decidim_admin_newsletter_organization_newsletter_id" }
      t.timestamps
    end
  end
end
