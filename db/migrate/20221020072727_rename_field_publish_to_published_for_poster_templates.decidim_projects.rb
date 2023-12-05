# This migration comes from decidim_projects (originally 20221020072234)
class RenameFieldPublishToPublishedForPosterTemplates < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_poster_templates, :publish, :published
  end
end
