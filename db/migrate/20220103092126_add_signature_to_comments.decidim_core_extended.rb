# This migration comes from decidim_core_extended (originally 20220103091901)
class AddSignatureToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :signature, :string
  end
end
