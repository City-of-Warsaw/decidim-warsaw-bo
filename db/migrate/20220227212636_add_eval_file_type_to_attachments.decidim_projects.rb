# This migration comes from decidim_projects (originally 20220227212553)
class AddEvalFileTypeToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_attachments, :eval_file_type, :string
  end
end
