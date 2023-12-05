# This migration comes from decidim_core_extended (originally 20220317122612)
class AddScrollTemplateToPageTopic < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_page_topics, :scroll_template, :boolean, default: false
  end
end
