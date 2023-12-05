class AddSignatureToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :signature, :string
  end
end
