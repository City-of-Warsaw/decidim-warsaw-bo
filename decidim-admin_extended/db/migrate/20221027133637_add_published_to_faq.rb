class AddPublishedToFaq < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_faqs, :published, :boolean
  end
end
