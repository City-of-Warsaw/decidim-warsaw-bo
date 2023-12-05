# This migration comes from decidim_projects (originally 20220202153638)
class AddSignatureToProjectVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :project_versions, :signature, :string
  end
end
