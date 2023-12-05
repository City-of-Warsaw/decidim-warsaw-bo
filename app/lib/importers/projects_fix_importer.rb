# frozen_string_literal: true

class Importers::ProjectsFixImporter < Importers::BaseImporter

  attr_accessor :import_errors


  def fixxx
    # Decidim::Projects::Project.find(14383).created_at.utc_offset # => 7200
    # Decidim::Projects::Project.find(15175).created_at.utc_offset # => 3600

    1.tap do
      Decidim::Projects::Project.where.not(old_id: nil).each do |project|
        offset = project.published_at.utc_offset
        project.update_column(:published_at, project.published_at - offset)
      end
    end

    arr = []
    1.tap do
      Decidim::Projects::Project.where.not(old_id: nil).each do |project|
        arr < project.id if project.published_at != project.created_at
      end
    end

    project = Decidim::Projects::Project.find(14383)
    offset = project.published_at.utc_offset
    project.update_column(:published_at, project.published_at - offset)


    i = Importers::ProjectsFixImporter.new(2020)
    i.read_data_from_file
    d = i.data[230]
    old = OldModels::Project.new(d)
    i.fix_project(old)


    i = Importers::ProjectsFixImporter.new(2020)
    Benchmark.realtime { i.fix_all_projects } #
    i.import_errors

    # PROD:
    # [16450, 26365, 26363, 26342, 26273, 26080, 26079, 25962, 25920, 25911, 25546, 25474, 25001, 24560, 23090, 23051, 29506, 29468, 28971, 27316, 27313, 27310, 27306, 27262, 27259, 27255, 27253, 27252, 27250, 27161, 27144, 27118, 26932, 26930, 26911, 26885, 26875, 26873, 26836, 26833, 26825, 26822, 26790, 26788, 26773, 26765, 26722, 26706, 26659, 26658, 26655, 26632, 26630, 26624, 26617, 26566, 26563, 26543, 26514, 26508, 26499]
  end


  def initialize(year, path = 'task-list-last/task-list-v1-editions-2015.json')
    @import_errors = []
    update_path(year, path)
  end

  def update_path(year, path = 'task-list-last/task-list-v1-editions-2015.json')
    @file_path = if year
                   "#{import_root_path}/task-list-last/task-list-v1-editions-#{year}.json"
                 else
                   "#{import_root_path}/#{path}"
                 end
  end


  def fix_all_projects
    [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
      update_path(year)
      read_data_from_file
      fix_all(year)
    end
  end


  def fix_all(year)
    data.each_with_index do |d, index|
      old = OldModels::Project.new(d)
      fix_project(old)
    end

    true
  end

  def fix_project(old)
    project = Decidim::Projects::Project.find_by(old_id: old.id)
    project.update_column(:created_at, old.created)
    return if old.status == 1 # kopia robocza

    if old.history.none?
      project.update_column(:published_at, old.created) if old.status.present? && old.status != 1
      return
    end

    old.history.each_with_index do |h, index|
      version = h.project_version

      if h.type == 1
        # publikujemy od razu
        project.update_column(:published_at, h.createTime)
        return
      end
    end
    @import_errors << project.old_id
    project
  end

  #  BRAKI DANYCH W UZYTKOWNIKACH:
  #
  # select distinct(decidim_author_id)
  # from decidim_coauthorships
  # where decidim_author_id in (SELECT id FROM "public"."decidim_users" WHERE ("city" IS NULL) AND ("updated_at" > '2023-01-25 00:00:01.987826'));
  def blank_users_data
    blank_user_ids = Decidim::Projects::SimpleUser.where(street: nil, street_number: nil, city: nil, zip_code: nil).where("updated_at > ?", DateTime.new(2023,01,26)).pluck(:id)
    Decidim::Coauthorship.where(decidim_author_id: blank_user_ids, decidim_author_type: 'Decidim::Projects::SimpleUser').count # => 0

    blank_user_ids = Decidim::User.where(street: nil, street_number: nil, city: nil, zip_code: nil).where("updated_at > ?", DateTime.new(2023,01,26)).pluck(:id)
    Decidim::Coauthorship.where(decidim_author_id: blank_user_ids, decidim_author_type: 'Decidim::UserBaseEntity').count # => 86

    sprawdzen = 0
    problems = []
    aktualizacji = []
    aktualizacje = []
    # ids = [15067, 22044, 61, 16023, 29461, 29799, 29792]
    # blank_user_ids.each do |user_id|
    [15067, 22044, 61, 16023, 29461, 29799, 29792].each do |user_id|
      ap user_id
      c = Decidim::Coauthorship.where(decidim_author_type: 'Decidim::UserBaseEntity').find_by(decidim_author_id: user_id)
      next unless c
      sprawdzen += 1

      u = Decidim::User.find(user_id)
      ap prev_ver = u.paper_trail.previous_version
      searching_version = true

      while searching_version
        unless prev_ver
          ap "PROBLEM - brak wersji!" * 5
          problems << "#{user_id}-#{c.coauthorable.state}-#{c.coauthor}"
          searching_version = false
          break
        end
        ap "szukamy dalej!"
        if !!(prev_ver.street && prev_ver.street_number && prev_ver.city && prev_ver.zip_code)

          u.phone_number = prev_ver.phone_number
          u.street = prev_ver.street
          u.street_number = prev_ver.street_number
          u.flat_number = prev_ver.flat_number
          u.zip_code = prev_ver.zip_code
          u.city = prev_ver.city
          u.save

          ap "Mamy wersje! " * 10
          aktualizacje << "#{prev_ver.street}  #{prev_ver.street_number} #{prev_ver.city} #{prev_ver.zip_code} #{prev_ver.phone_number} #{prev_ver.flat_number}"
          aktualizacji << user_id
          break
        else
          ap "sprawdzam kolejna wersje"
          ap prev_ver = prev_ver.paper_trail.previous_version
        end
      end
    end

    ap u = Decidim::User.find(user_id)
    ap prev_ver = u.paper_trail.previous_version
    ap prev_ver = prev_ver.paper_trail.previous_version

    ids = [15067,
           22044,
           61,
           16023,
           29461,
           29799,
           29792]


    user_id = 29792
    u = Decidim::User.find(user_id)
    prev_ver = u.paper_trail.previous_version
    prev_ver = prev_ver.paper_trail.previous_version
    !!(prev_ver.street && prev_ver.street_number && prev_ver.city && prev_ver.zip_code)


    u = Decidim::User.find(23217)
    u.versions.find(86554).reify.street
  end
end
