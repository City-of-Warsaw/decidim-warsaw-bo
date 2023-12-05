# frozen_string_literal: true

class Importers::RecipientsImporter < Importers::BaseImporter

  def initialize(path='dictionary-recipients-list-v1.json')
    @file_path = "#{import_root_path}/#{path}"
  end

  # Importers::RecipientsImporter.new.call
  def call
    read_data_from_file
    process_file_data
    true
  end

  def process_file_data
    data.each do |d|
      item = OldModels::Recipient.new(d)
      # Coauthorship
      r = Decidim::AdminExtended::Recipient.find_by id: item.id
      if r
        r.update(name: item.name)
      else
        Decidim::AdminExtended::Recipient.create(id: item.id, name: item.name)
      end
    end
    true
  end

  def remove_all_data
    reset_table
    reset_index
  end


  private

  def reset_table
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_admin_extended_recipients CASCADE;")
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_admin_extended_recipients_id_seq', max(id)) FROM decidim_admin_extended_recipients;")
  end

end