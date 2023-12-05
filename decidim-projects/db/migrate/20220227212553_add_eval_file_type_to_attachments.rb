class AddEvalFileTypeToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_attachments, :eval_file_type, :string
  end
end
