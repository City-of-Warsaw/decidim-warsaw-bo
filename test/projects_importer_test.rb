# frozen_string_literal: true

class ProjectsImporterTest

  # mogrify: Corrupt JPEG data: found marker 0xd3 instead of RST6 `/tmp/mini_magick20221113-18951-1hcqs2s.jpg' @ warning/jpeg.c/JPEGWarningHandler/390.

  # 5, old_id: 3827 blad - realizacje 2017 rok
  # => old_id: 18653 -problem realizacji
  #
  #
  # 25045
  #
  def test_projects_history
    project = Decidim::Projects::Project.find 8649
    project.attachment_context_for_import = :admin
    # Decidim::Projects::Project.last.destroy
    i = Importers::ProjectsImporter.new  2023
    i.read_data_from_file
    # d = i.data[3375]
    d = i.data[1731]
    # d = i.data[207] # - komentarz usuniety przez usera
    old = OldModels::Project.new(d)
    # i.import_realization(old)
    # i.process_project(old, 1)
    # Decidim::Projects::Project.last.id
    a = old.attachments[0]

    author = Decidim::User.first
    project = Decidim::Projects::Project.find(4774)
    ap old.comments.first.build_comment(project, author)

  end

  # move implementations from Carierwave to AS
  def move_implementations
    project = p = Decidim::Projects::Project.find 13
    file_name = 'bo-1611141579_foto_obrocony-tagami.jpg'
    file_path = "/Users/przemad/workspace/decidim_bo/#{file_name}"
    File.open(file_path) do |file|
      attachment_attrs = {
        title: { I18n.locale => file_name },
        attached_to: project,
        file: file,
        image_alt: 'image-alt',
        main_attachment: false
      }
      project.old_implementation_photos << Decidim::Projects::ImplementationPhotoOld.new(attachment_attrs)
    end

    p.old_implementation_photos.each do |old|
      old.title['pl']
      photo = p.implementation_photos.create(image_alt: old.image_alt)
      url = "/Users/przemad/workspace/decidim_bo/public#{old.file.url}"

      photo.file.attach(io: File.open(url), filename: 'testowy.jpg')
    end

    # problem implementacji dla projektow_id: [22969, 6658]
    arr = []
    ps = []
    1.tap do
      Decidim::Projects::ImplementationPhoto.all.each do |p|
        unless p.file.attached?
          arr << p.id
          ps << p.project_id
        end
      end
    end
  end

  # move implementations from Carierwave to AS on staging env
  def migrate_implementation_photos_to_active_storage
    project_ids = Decidim::Projects::ImplementationPhotoOld.pluck(:attached_to_id)
    1.tap do
      project_ids.each do |project_id|
        ap "project_id: #{project_id}"
        project = Decidim::Projects::Project.find project_id
        next if project.implementation_photos.any?

        project.old_implementation_photos.each do |old|
          filename = old.title['pl']
          photo = project.implementation_photos.create(image_alt: old.image_alt)
          file_path = "/var/www/decidim/current/public#{old.file.url}"
          unless File.file?(file_path)
            next
          end
          File.open(file_path) do |file|
            photo.file.attach(io: file, filename: filename)
          end
        end
      end
    end
  end

  def test_new_import
    i = Importers::ProjectsImporter.new(2021)
    i.read_data_from_file
    d = i.data[2724]
    old = OldModels::Project.new(d)
    i.import_realization(old)

    project = Decidim::Projects::Project.find 2725
    project.implementation_photos.last
  end


  # reimport komentarzy
  # usunac najpierw:
  # - komentrze
  # - decidim_searchable_resources  where(resource_type: 'Decidim::Comments::Comment')
  # - versions where(item_type: 'Decidim::Comments::Comment')
  def fix_all_comments
    PaperTrail.request(enabled: false) do
      Decidim::Comments::Comment.delete_all
      Decidim::SearchableResource.where(resource_type: 'Decidim::Comments::Comment').delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM versions CASCADE where item_type = 'Decidim::Comments::Comment';")
      Decidim::Projects::Project.update_all(comments_count: 0)
    end

    Benchmark.realtime do
      [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
        i = Importers::ProjectsImporter.new year
        i.read_data_from_file
        PaperTrail.request(enabled: false) do
          Decidim::Projects::Project.transaction do
            i.data.each_with_index do |d, index|
              old = OldModels::Project.new(d)
              ap "#{year}, old_id: #{old.id}, index: #{index}"
              project = Decidim::Projects::Project.find_by(old_id: old.id)
              next unless project
              i.process_comments(old, project)
            end
          end
        end
        true
      end
      true
    end
  end

  def fix_all_implementations_date
    Benchmark.realtime do
      [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
        Decidim::Projects::Project.transaction do
          fix_implementation_date(year)
        end
      end
    end
  end

  def fix_implementation_date(year)
    i = Importers::ProjectsImporter.new year
    i.read_data_from_file
    i.data.each_with_index do |d, index|
      ap "year: #{year}, index: #{index}"
      old = OldModels::Project.new(d)
      next if old.realization.blank? || old.realization.history.none?

      project = Decidim::Projects::Project.find_by(old_id: old.id)
      next unless project

      project.implementations.delete_all
      i.process_realizations(old, project)
    end
    true
  end

  # Przypisuje biura z projektow do aktualnych projektow
  # ProjectsImporterTest.new.fix_assignment_departments_to_projects
  def fix_assignment_departments_to_projects
    multiple_problems = [] # => [19091]
    missing_offices = [] # => [17987, 25829, 25314, 29093]
    [2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
      i = Importers::ProjectsImporter.new year
      i.import_errors = []
      i.read_data_from_file
      rows_num = i.data.size
      counter = 0
      1.tap do
        i.data.each_with_index do |d, index|
          ap "year: #{year}, index: #{index}/#{rows_num} / #{i.import_errors.size}"
          old = OldModels::Project.new(d)
          p = Decidim::Projects::Project.find_by(old_id: old.id)
          raise "brak projektu #{old.id}" unless p
          next if p.current_department_id.present?
          next if (old.assignment.officeId.blank? || old.assignment.officeId == 0) && (old.assignment.unitId.blank? || old.assignment.unitId == 0)
          # raise "jednoczesnie biuro i jednostka #{old.id}" if old.assignment.officeId.present? && old.assignment.officeId != 0 && old.assignment.unitId.present? && old.assignment.unitId != 0

          if old.assignment.officeId.present? && old.assignment.officeId != 0 && old.assignment.unitId.present? && old.assignment.unitId != 0
            multiple_problems << old.id
            next
          end

          ap old.assignment
          counter += 1

          # aktualnie tylko projekt 24680 ma current_department_id ustawiony
          office = if old.assignment.officeId.present? && old.assignment.officeId != 0
                     Decidim::AdminExtended::Department.where(old_type: 'office').find_by(old_id: old.assignment.officeId)
                   elsif old.assignment.unitId.present? && old.assignment.unitId != 0
                     Decidim::AdminExtended::Department.where(old_type: 'unit').find_by(old_id: old.assignment.unitId)
                   else
                     nil
                   end
          # raise "brak biura dla #{old.id}" unless office
          unless office
            missing_offices << old.id
            next
          end

          current_department_id = if office.id == 24 || office.id == 59
                                    # Biuro Cyfryzacji Miasta (id: 24) i Miejskie Centrum Sieci Danych (id: 59) połączyły się i zmieniły nazwę na Biuro Informatyki (nowy: 71)
                                    71
                                  elsif office.id == 31
                                    # Biuro Kadr i Szkoleń (31) zmieniło nazwę na Biuro Zarządzania Zasobami Ludzkimi (74)
                                    74
                                  else
                                    office.id
                                  end

          p.update_column(:current_department_id, current_department_id)
          # p.department_assignments.create(department: office)
        end
      end
    end
    # i.import_errors
    # counter
  end

  # arr = check_all_attachments_number
  def check_all_attachments_number
    errors = {}
    Benchmark.realtime do
      [2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
        errors[year] = check_attachments_number(year)
        ap "#{year}: #{errors[year].size}"
        p errors
        # errors[year] = { year: year, size: err_arr.size, arr: err_arr }
      end
    end
    errors
  end

  def check_attachments_number(year)
    i = Importers::ProjectsImporter.new year
    i.import_errors = []
    i.read_data_from_file
    rows_num = i.data.size
    i.data.each_with_index do |d, index|
      ap "year: #{year}, index: #{index}/#{rows_num} / #{i.import_errors.size}"
      old = OldModels::Project.new(d)
      p = Decidim::Projects::Project.find_by(old_id: old.id)
      next unless p
      next if old.attachments.size == 0

      # if old.attachments.size != p.files.count
      #   i.import_errors << old.id
      # end
      old.attachments.each do |old_attachment|
        next if p.files.where("title ->> 'pl' = ?", old_attachment.originalName).first

        ap "brakuje #{old_attachment.originalName}"
        # import_attachment(old_attachment, p, i)
      end
    end
    i.import_errors
  end

  def import_attachment(old_attachment, project, i)
    project.attachment_context_for_import = :migration
    url = old_attachment.url
    file_name = old_attachment.originalName
    file_path = "#{i.import_root_path}#{url}"
    File.open(file_path) do |file|
      attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
      vf = Decidim::Projects::VariousFile.new(attachment_attrs)
      vf.valid?
      ap vf.errors.full_messages
      # vf.attached_to = project
      # vf.save
      project.files << vf
      # project.files << Decidim::Projects::VariousFile.new(attachment_attrs)
    end
  end


  # $ file -b --mime /Users/przemad/BO-dane/migration-2022-11-07/uploads/tasks/1643146002_zalacznik_0_29767_70900.doc
  # => application/msword; charset=binary
  def test_file_wird
    MiniMime.lookup_by_filename(file_path).content_type
    MiniMime.lookup_by_content_type(file_path).content_type
    MiniMime.lookup_by_content_type(file_path).content_type
    Marcel::Magic.by_magic(file).try(:type)
    Marcel::Magic.all_by_magic(file)

    file_name = '1653889484_zalacznik_0_18199.xls'
    file_path = '/Users/przemad/BO-dane/migration-2022-10-14/uploads/tasks/1653889484_zalacznik_0_18199.xls'
    project = Decidim::Projects::Project.find_by old_id: 29348
    project.attachment_context_for_import = :migration

    File.open(file_path) do |file|
      attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
      vf = Decidim::Projects::VariousFile.new(attachment_attrs)
      vf.valid?
      ap vf.errors.full_messages

      ap "vf.file.content_type: #{vf.file.content_type}"

      project.files << vf
    end
  end

  def check_map_pins_size
    path = "task-list-v1-editions-2021.json" # => local 17 min / 2813
    i = Importers::ProjectsImporter.new path
    i.read_data_from_file
    size = 0 # 5033 - wszystkie, # 4398 - published # 250 ogolnomiejskich, 200 jest ok,
    size = 0
    count = 0
    h = {}
    projects = []
    1.tap do
      i.data.each_with_index do |d, index|
        ap "index: #{index}, old_id: #{d['id']}"
        old = OldModels::Project.new(d)
        project = Decidim::Projects::Project.find_by old_id: old.id
        # STARY: 590 + 3840 = 4430  / 2243 projekty
        # size += 1 if !old.status.nil? && old.status!="" && old.status!="1" && old.status!=1 # 2243 publiczne projekty
        # count += 1 if !old.status.nil? && old.status!="" && old.status!="1" && old.status!=1 && project.published? # te same opublikowane

        # size += old.mapPins.size if project.published? # 4398
        # count += 1 if project.scope && project.scope.code == "OM"
        # count += 1 if old.projectLevel == "Ogólnomiejski" && project.published?
        # size += old.mapPins.size if old.projectLevel == "Ogólnomiejski" && project.published? # => 200 proj -> 586 lok / 590 u nich
        # size += old.mapPins.size if old.projectLevel != "Ogólnomiejski" && project.published? # => 2043 proj -> 3812 lok / 3840 u nich
        # size += old.mapPins.size if project.published? && project.scope.id == 21 # => 147 lok
        # size += old.mapPins.size if project.published? && project.scope.id == 22 # => 147 lok
        # if project.published?
        #   h[project.scope.id] = 0 unless h[project.scope.id]
        #   h[project.scope.id] += old.mapPins.size
        # end

        size += 1
        if project.published? && project.scope.id == 34 && old.categories.include?('kultura') && old.recipients.include?('dzieci')
          projects << project
          size += 1
        end
      end
    end

    1.tap do
      PaperTrail.request(enabled: false) do
        Decidim::Projects::Project.where(edition_year: 2023, state: 'evaluation').update_all(state: 'published')
        Decidim::Projects::Project.where(edition_year: 2023, state: 'evaluation').each do |p|
        end
      end
    end
  end

  def xxx
    1.tap do
      [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
        i = Importers::ProjectsImporter.new "task-list-v1-editions-#{year}.json"
        i.read_data_from_file
        i.data.each_with_index do |d, index|
          ap "year: #{year}, #{index}"
          old = OldModels::Project.new(d)
          ap "old_id: #{old.id}, esog: #{old.number}"

          if old.realization&.revoked
            p = Decidim::Projects::Project.find_by old_id: old.id
            p.update_column(:implementation_status, 0)
          end
        end
      end
    end

    i = Importers::ProjectsImporter.new path
    i.read_data_from_file
    1.tap do
      # i.data.first(10).each_with_index do |d, index|
      i.data.each_with_index do |d, index|
        ap index
        old = OldModels::Project.new(d)
        ap "old_id: #{old.id}, esog: #{old.number}"
        ap old.verification
      end
    end

    1.tap do
      PaperTrail.request(enabled: false) do
        path = "task-list-v1-editions-2022.json"
        i = Importers::ProjectsImporter.new path
        i.read_data_from_file
        i.data.each_with_index do |d, index|
          ap index
          old = OldModels::Project.new(d)
          p = Decidim::Projects::Project.find_by old_id: old.id
          p.formal_result = old.verification.formalResult.nil? ? nil : old.verification.formalResult == 1
          p.meritorical_result = old.verification.meritResult.nil? ? nil : old.verification.meritResult == 1
          p.reevaluation_result = old.verification.reevaluationResult.nil? ? nil : old.verification.reevaluationResult == 1
          p.save
        end
      end
    end
  end

  def xxx_test
    reload!
    path = "task-list-last/task-list-v1-editions-2021.json"
    i = Importers::ProjectsImporter.new path
    i.reset_table
    i.read_data_from_file
    Benchmark.realtime { i.call }
    d = i.data[1291]
    old.universalDesign == 1

    old = OldModels::Project.new(d)
    old = i.find_old("22881")

    project = i.process_project(old)
    i.process_comments(old, project)

    h = old.history.first
    history_type = h[:type]
    createTime = h[:createTime]
    version = h.project_version
    user = i.find_creator(old, h[:userId])
    user = i.find_creator(old, old.creatorId)



    Benchmark.realtime { i.read_data_from_file }
    old = OldModels::Project.new(i.data[1734])
    # PaperTrail.request(enabled: false) do
    i.process_project(old)
    # end

    old.history.each{|h| ap h if h[:type] != "-1" }
    old.history.each{|h| ap h if h[:type] != "-1" }

    old = i.find_old_proj(21998) # global
    old = i.find_old_proj(21759) # isPaper


    # PROBLEM:
    # path = 'files_to_migrate/wawa-full/projects/2.json'
    # old = OldModels::Project.new(i.data[760])
    # costOfOperation\":\"-1000000\


    ap JSON.parse old.history[0].data #=> projekt zgloszony / status = 1 - niewidoczny status
    ap JSON.parse old.history[15].data #=> projekt zgloszony / status = 3

    old = OldModels::Project.new(i.data[180])
    old.history.size
    ap JSON.parse(old.history[1].data).keys # => 31
    ap JSON.parse(old.history[19].data).keys # => 31


    # component = Decidim::ParticipatoryProcess.find(old.taskGroupId).components.first
    component = @editions[old.taskGroupId].components.first

    p = old.build_project
    p.component = component
    p.decidim_scope_id = @districts[old.mainRegionId]
    p.save

    ActiveRecord::Base.transaction do
    end

    importer.test_field('isPaper')
  end


  def xxx_attachments
    p = Decidim::Projects::Project.last
    pdf = WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>')


    old_project.attachments.each do |a|
      url = a.url
      file_name = a.originalName
      file_path = "#{directory}#{url}"
      # File.file?(file_path)
      File.open(file_path) do |file|
        attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
        project.files << Decidim::Projects::VariousFile.new(attachment_attrs)
      end
    end
  end

  def stats
    11.times do |index|
      path = "files_to_migrate/wawa-full/projects/#{index + 1}.json"
      i = Importers::ProjectsImporter.new path
      Benchmark.realtime { i.read_data_from_file }
      a = i.data.map{|e| e['taskGroupId']}.uniq
      ap "#{index+1}: #{a}"
    end

    # ilosc projektow w kazdym pliku w danej edycji
    11.times do |index|
      path = "files_to_migrate/wawa-full/projects/#{index + 1}.json"
      i = Importers::ProjectsImporter.new path
      Benchmark.realtime { i.read_data_from_file }
      ap path
      @editions.each do |edition_id, edition|
        ap "#{edition.edition_year}: #{i.data.select{ |e| e['taskGroupId'].to_i == edition_id }.size} / #{i.data.size}"
      end
    end

    # ilosc zaimportowanych projektow
    (2015..2023).each do |year|
      component_id = Decidim::ParticipatoryProcess.find_by(edition_year: year).components.where(manifest_name: "projects").first.id
      ap "#{year}: #{Decidim::Projects::Project.where(decidim_component_id: component_id).count}"
    end

    # ilosc wszystkich projektow od Asseco w plikach
    sum_editions = {}
    8.times { |i| sum_editions[i+1] = 0 }
    11.times do |index|
      path = "files_to_migrate/wawa-full/projects/#{index + 1}.json"
      i = Importers::ProjectsImporter.new path
      Benchmark.realtime { i.read_data_from_file }
      ap path
      1.tap do
        i.data.each do |d|
          sum_editions[d['taskGroupId'].to_i] += 1
        end
      end
    end
    editions = {}
    Decidim::ParticipatoryProcess.all.each { |e| editions[e.old_id] = e }
    sum_editions.each do |k,v|
      ap "#{editions[k].edition_year}: #{v}"
    end
  end


  # ID uzytkownika / ID projektu
  # 10378
  # 18237
  # 13451
  # 11778
  # 17115: 18193,
  # 13864: 16300,
  # 11804: 13352,
  # 10195: 12860,
  # 8728: 9912
  # 2418: 5191, 5181,
  # 2415: 5172,

  # ap r = users_check2
  def users_check2
    res = {}
    users_ids = [1080]
    # users_ids = [739, 939, 1044, 1189, 1243, 1244, 1295, 1307, 1470, 2298, 8571, 8723, 8956, 8957, 9207, 9690, 9754, 9947, 9970, 11748, 13230, 13366, 13657, 13834, 13943, 13944, 16394, 17060, 21988, 24837, 25694, 25699, 25727, 25855, 25860, 26004, 26012, 26017, 26018, 26019, 26022, 26029, 29714]
    users_ids.each do |user_id|
      res[user_id] = []
    end

    1.tap do
      9.times do |index|
        ap '- ' * 20
        # 2.times do |index|
        path = "files_to_migrate/24_02_2022_task-list-data/task-list-v1-editions-#{index + 1}.json"
        ap "START file: #{path}"
        i = Importers::ProjectsImporter.new path
        i.read_data_from_file

        users_ids.each do |user_id|
          a = i.data.select{ |e| e['creatorId'].to_i == user_id }.map{|e| e['id']}.uniq
          ap "#{user_id}:"
          ap a
          res[user_id] << { "#{index}": a }
        end
      end
    end
    1.tap do
      9.times do |index|
        ap '- ' * 20
        # 2.times do |index|
        path = "files_to_migrate/24_02_2022_task-list-data/task-list-v1-editions-#{index + 1}.json"
        ap "START file: #{path}"
        i = Importers::ProjectsImporter.new path
        i.read_data_from_file

        i.data.each_with_index do |d, index|
          ap index
          return if !d['privateFiles'].empty?
        end
      end
    end
    res
  end

  def xxxxxxx
    a = []
    a = i.problems.map(&:old_id)
    Decidim::User.where.not(all_old_ids: nil).map(&:old_id)
    Decidim::User.where.not(all_old_ids: nil).map(&:all_old_ids).flatten.map{|e| e.split(',')}.flatten.map(&:to_i)
    users_ids = [26029, 29714, 13944, 17060, 26019, 13834, 16394, 26004, 13657, 9690, 9970, 1295, 9754, 9947, 1044, 2298]
    users_ids = [26022, 25727, 24837, 13943, 13366, 26018, 26017, 26012, 25860, 25855, 25699, 25694, 13230, 11748, 9207, 8957, 8956, 21988, 8723, 8571, 1470, 1307, 1244, 1243, 1189, 939, 739]
  end

  def remove_evaluation_docs_from_2017
    p = Decidim::Projects::Project.find(17916)

    1.tap do
      Decidim::Projects::Project.where(edition_year: 2017).each do |p|
        p.formal_evaluation.documents.destroy_all if p.formal_evaluation
        p.meritorical_evaluation.documents.destroy_all if p.meritorical_evaluation
        p.reevaluation.documents.destroy_all if p.reevaluation
      end
    end
    i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2017.json"
    i.import_all_verifications
  end

  # Decidim::Projects::Project.count
  # Decidim::Follow.count
  # Decidim::Follow.where(decidim_followable_type: 'Decidim::Projects::Project').count
  # Decidim::Follow.group(:coauthorable_type).count
  #
  # Usuwanie dodanych automatycznie followable
  def fix_followable_projects
    count = 0
    Decidim::Follow.where(decidim_followable_type: 'Decidim::Projects::Project').each do |follow|
      proj = follow.followable
      unless proj
        ap "brak dla #{follow.id}"
        follow.destroy
        next
      end
      if follow.created_at - 1.minute < proj.created_at && proj.created_at < follow.created_at + 1.minute
        count += 1
        follow.destroy
      end
    end
    count
  end

end