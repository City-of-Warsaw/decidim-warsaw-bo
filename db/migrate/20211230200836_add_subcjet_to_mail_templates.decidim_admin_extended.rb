# This migration comes from decidim_admin_extended (originally 20211230200727)
class AddSubcjetToMailTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_mail_templates, :subject, :string
  end
end
