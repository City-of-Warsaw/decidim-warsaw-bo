class AddAltToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_attachments, :image_alt, :string
  end
end
