class AddAllowReturningProejctColumnToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_departments, :allow_returning_projects, :boolean, default: false
    if table_exists?(:decidim_projects_projects)
      add_column :decidim_projects_projects, :return_reason, :text
    end
  end
end
