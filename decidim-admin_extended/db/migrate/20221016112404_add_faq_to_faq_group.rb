class AddFaqToFaqGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_faqs, :faq_group
  end
end
