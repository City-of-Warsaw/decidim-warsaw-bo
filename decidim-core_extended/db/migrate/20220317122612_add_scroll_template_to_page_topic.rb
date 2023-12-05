class AddScrollTemplateToPageTopic < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_page_topics, :scroll_template, :boolean, default: false
  end
end
