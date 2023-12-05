# frozen_string_literal: true

class Importer

  # Importer.new.call
  def call
    # remove data
    Importers::BannedWordsImporter.new.remove_all_data
    Importers::EditionsImporter.new.remove_all_data
    Importers::RecipientsImporter.new.remove_all_data
    Importers::CategoriesImporter.new.remove_all_data
    Importers::RegionsImporter.new.remove_all_data
    Importers::DistrictsImporter.new.remove_all_data

    # import data
    Importers::BannedWordsImporter.new.call
    Importers::RecipientsImporter.new.call
    Importers::CategoriesImporter.new.call
    Importers::RegionsImporter.new.call

    Importers::EditionsImporter.new.call

    Generators::DepartmentsGenerator.new.call

    Generators::DistrictsGenerator.new.call

    Importers::DistrictsImporter.new.call

    Importers::UnitsImporter.new.call

    Importers::OfficesImporter.new.call

    importer = Importers::UsersImporter.new
    importer.call

    Importers::ProjectsImporter.new.call
  end
end