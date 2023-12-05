# This migration comes from decidim_admin_extended (originally 20221016112404)
class AddFaqToFaqGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_faqs, :faq_group
  end
end
