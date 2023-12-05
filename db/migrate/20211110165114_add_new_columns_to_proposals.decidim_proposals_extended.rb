# This migration comes from decidim_proposals_extended (originally 20211110163509)
class AddNewColumnsToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :rank_number, :integer
    add_column :decidim_proposals_proposals, :esog_number, :integer
    add_column :decidim_proposals_proposals, :is_paper, :boolean, default: false
    add_column :decidim_proposals_proposals, :short_description, :text
    add_column :decidim_proposals_proposals, :localization_additional_info, :text
    add_column :decidim_proposals_proposals, :availability_description, :text
    add_column :decidim_proposals_proposals, :universal_design, :boolean, default: nil
    add_column :decidim_proposals_proposals, :universal_design_argumentation, :text
    add_column :decidim_proposals_proposals, :budget_description, :text
    add_column :decidim_proposals_proposals, :future_maintenance, :boolean, default: nil
    add_column :decidim_proposals_proposals, :future_maintenance_description, :text
    add_column :decidim_proposals_proposals, :future_maintenance_value, :decimal, precision: 5, scale: 2
    add_column :decidim_proposals_proposals, :negative_verification_reason, :text
    add_column :decidim_proposals_proposals, :project_implementation_effects, :text
    add_column :decidim_proposals_proposals, :producer_list, :text
    add_column :decidim_proposals_proposals, :remarks, :text

    rename_column :decidim_proposals_proposals, :total_budget_value, :budget_value
    rename_column :decidim_proposals_proposals, :nececisty_description, :justification_info
  end
end
