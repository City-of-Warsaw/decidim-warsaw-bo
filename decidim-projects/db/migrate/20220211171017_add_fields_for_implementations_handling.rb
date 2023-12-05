class AddFieldsForImplementationsHandling < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :implementation_on_main_site_slider, :boolean, default: false
    add_column :decidim_attachments, :main_attachment, :boolean, default: false
  end
end
