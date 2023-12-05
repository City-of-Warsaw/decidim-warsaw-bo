# frozen_string_literal: true

class Importers::CocreatorsImporter < Importers::BaseImporter

  def initialize(path='cocreators-list-v1.json')
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
      item = OldModels::Cocreator.new(d)

    end
    true
  end

  def find_old(old_id)
    read_data_from_file if data.blank?
    d = data.select{ |p| p['id'] == old_id.to_s }
    old_model.new(d.first)
  end

  def old_model
    OldModels::Cocreator
  end


  def remove_all_data
    # reset_table
    # reset_index
  end


  private

  def reset_table
    # ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_projects_regions CASCADE;")
  end

  def reset_index
    # ActiveRecord::Base.connection.execute("SELECT setval('decidim_projects_regions_id_seq', max(id)) FROM decidim_projects_regions;")
  end

end