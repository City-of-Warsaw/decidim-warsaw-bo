# This migration comes from decidim_projects (originally 20220829195002)
class ChangeDistrictLimitsDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_participatory_processes, :global_scope_projects_voting_limit, from: 15, to: 10
    change_column_default :decidim_participatory_processes, :district_scope_projects_voting_limit, from: 10, to: 15
  end
end
