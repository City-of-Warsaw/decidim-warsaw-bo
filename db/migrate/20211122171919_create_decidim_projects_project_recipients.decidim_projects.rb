# This migration comes from decidim_projects (originally 20211122165809)
class CreateDecidimProjectsProjectRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_recipients do |t|
      t.references :decidim_projects_project, index: { name: 'index_on_recipients_on_projects_id'}
      t.references :decidim_admin_extended_recipient, index: { name: 'index_on_projects_on_recipients_id'}

      t.timestamps
    end
  end
end
