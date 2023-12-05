class AddImplementationConnectedFieldsToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :implementation_status, :integer, default: nil
  end
end
