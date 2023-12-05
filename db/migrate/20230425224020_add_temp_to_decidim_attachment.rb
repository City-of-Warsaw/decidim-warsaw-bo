class AddTempToDecidimAttachment < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_attachments,:temporary_file,:boolean, :default => false
  end
end
