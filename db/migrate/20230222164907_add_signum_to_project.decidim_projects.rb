# This migration comes from decidim_projects (originally 20230222164650)
class AddSignumToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :signum_spr_id, :string
    add_column :decidim_projects_projects, :signum_nr_kancelaryjny, :string
    add_column :decidim_projects_projects, :signum_kor_id, :string
    add_column :decidim_projects_projects, :signum_znak_sprawy, :string
    add_column :decidim_projects_projects, :signum_registered_at, :datetime
    add_column :decidim_projects_projects, :signum_registered_by_user_id, :integer
  end
end
