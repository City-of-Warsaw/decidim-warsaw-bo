class AddSignatureToProjectVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :project_versions, :signature, :string
  end
end
