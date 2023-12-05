# This migration comes from decidim_proposals_extended (originally 20211114172902)
class AddAttachmentTypeToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_attachments, :attachment_type, :string
  end
end
