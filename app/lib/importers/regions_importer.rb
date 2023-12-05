# frozen_string_literal: true

class Importers::RegionsImporter < Importers::BaseImporter

  def initialize(path='dictionary-regions-list-v1.json')
    @file_path = "#{import_root_path}/#{path}"
  end

  # Importers::RegionsImporter.new.call
  def call
    read_data_from_file
    process_file_data
    true
  end

  def process_file_data
    data.each do |d|
      item = OldModels::Region.new(d)
      Decidim::Projects::Region.create(id: item.id, name: item.name, old_id: item.id)
    end
    true
  end

  def remove_all_data
    reset_table
    reset_index
  end


  private

  def reset_table
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_projects_regions CASCADE;")
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_projects_regions_id_seq', max(id)) FROM decidim_projects_regions;")
  end

end