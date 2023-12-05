class AddSystemNameToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :system_name, :string
  end
end
