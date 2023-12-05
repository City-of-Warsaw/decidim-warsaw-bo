# frozen_string_literal: true

class Importers::CategoriesImporter < Importers::BaseImporter

  def initialize(path='dictionary-categories-list-v1.json')
    @file_path = "#{import_root_path}/#{path}"
  end

  # Importers::RecipientsImporter.new.call
  def call
    read_data_from_file
    process_file_data
    true
  end

  def process_file_data
    organization = Decidim::Organization.first
    data.each do |d|
      item = OldModels::Category.new(d)

      a = Decidim::Area.find_by id: item.id
      if a
        a.update_column(:name, item.name)
      else
        Decidim::Area.create(id: item.id, name: { pl: item.name }, organization: organization)
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
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_areas CASCADE;")
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_areas_id_seq', max(id)) FROM decidim_areas;")
  end

end