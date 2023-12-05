# frozen_string_literal: true

class Importers::UnitsImporter < Importers::BaseImporter

  def initialize(path='dictionary-unit-list-v1.json')
    @file_path = "#{import_root_path}/#{path}"
  end

  # Importers::UnitsImporter.new.call
  def call
    read_data_from_file
    process_file_data
    true
  end

  def process_file_data
    data.each do |d|
      item = OldModels::Unit.new(d)
      d = Decidim::AdminExtended::Department.find_by name: item.name
      if d
        d.update(old_id: item.id, old_type: item.old_type)
      else
        Decidim::AdminExtended::Department.create!(name: item.name, old_id: item.id, old_type: item.old_type)
      end
    end
    true
  end

  def remove_all_data
    # reset_table
    # reset_index
  end


  private

  def reset_table
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_admin_extended_departments CASCADE;")
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_admin_extended_departments_id_seq', max(id)) FROM decidim_admin_extended_departments;")
  end

end