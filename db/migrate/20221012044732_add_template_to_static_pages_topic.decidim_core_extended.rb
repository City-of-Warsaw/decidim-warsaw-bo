# This migration comes from decidim_core_extended (originally 20221012044610)
class AddTemplateToStaticPagesTopic < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_page_topics, :template, :string, default: nil
  end
end
