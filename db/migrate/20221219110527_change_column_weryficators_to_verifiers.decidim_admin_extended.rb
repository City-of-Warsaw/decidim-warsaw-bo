# This migration comes from decidim_admin_extended (originally 20221219110449)
class ChangeColumnWeryficatorsToVerifiers < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_admin_extended_documents, :werificators, :verifiers
  end
end
