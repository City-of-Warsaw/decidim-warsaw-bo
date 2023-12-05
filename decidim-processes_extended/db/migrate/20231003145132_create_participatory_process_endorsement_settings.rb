# frozen_string_literal: true

class CreateParticipatoryProcessEndorsementSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_processes_extended_endorsement_list_settings do |t|
      t.references :decidim_participatory_process, index: { name: 'decidim_endorsement_settings_participatory_process_id' }
      t.string :header_description
      t.string :footer_description
      t.timestamps
    end
  end
end
