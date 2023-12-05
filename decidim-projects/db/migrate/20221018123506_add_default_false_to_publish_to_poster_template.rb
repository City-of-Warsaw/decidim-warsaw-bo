class AddDefaultFalseToPublishToPosterTemplate < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_projects_poster_templates, :publish, false
  end
end
