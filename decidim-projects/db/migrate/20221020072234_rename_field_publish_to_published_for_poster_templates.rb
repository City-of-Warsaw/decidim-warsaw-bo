class RenameFieldPublishToPublishedForPosterTemplates < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_projects_poster_templates, :publish, :published
  end
end
