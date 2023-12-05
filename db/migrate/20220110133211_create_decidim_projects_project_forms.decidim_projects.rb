# This migration comes from decidim_projects (originally 20220110132123)
class CreateDecidimProjectsProjectForms < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_projects_project_customizations do |t|
      t.references :decidim_participatory_process, index: { name: 'decidim_project_custom_on_participatory_process_id' }
      t.jsonb :additional_attributes
      t.jsonb :custom_names

      t.timestamps
    end
  end
end
