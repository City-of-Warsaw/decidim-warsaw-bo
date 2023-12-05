# frozen_string_literal: true

class Importers::DistrictsImporter < Importers::BaseImporter

  def initialize(path='dictionary-districts-list-v1.json')
    @file_path = "#{import_root_path}/#{path}"
    @organisation = Decidim::Organization.last
  end

  def call
    read_data_from_file
    PaperTrail.request(enabled: false) do
      process_file_data
    end
    true
  end

  # Importers::DistrictsImporter.new.call
  def process_file_data
    # data.first(2).each do |d|
    data.each do |d|
      item = OldModels::District.new(d)
      d = Decidim::Scope.find_by(name: { pl: item.name })
      raise "BRAK: #{item.name}" unless d
      next if d.old_ids&.include?(item.id)

      if d.old_ids
        d.old_ids << item.id
      else
        d.old_ids = [item.id]
      end
      # d.old_ids = []
      d.save

    end
    true
  end

  def remove_all_data
    # reset_table
    # reset_index
    Decidim::Scope.where.not(old_id: nil).destroy_all
  end


  private

  def reset_table
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_scopes CASCADE;")
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_projects_regions_id_seq', max(id)) FROM decidim_projects_regions;")
  end

end