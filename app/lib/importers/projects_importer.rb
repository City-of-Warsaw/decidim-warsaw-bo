# frozen_string_literal: true

class Importers::ProjectsImporter < Importers::BaseImporter

  attr_accessor :import_errors

  def initialize(year, path = 'task-list-last/task-list-v1-editions-2015.json')
    @file_path = if year
                   "#{import_root_path}/task-list-last/task-list-v1-editions-#{year}.json"
                 else
                   "#{import_root_path}/#{path}"
                 end

    @editions = {}
    Decidim::ParticipatoryProcess.all.each { |e| @editions[e.old_id] = e }

    @regions = {}
    Decidim::Projects::Region.all.each { |e| @regions[e.old_id] = e }

    @recipients = {}
    Decidim::AdminExtended::Recipient.all.each { |e| @recipients[e.name] = e }

    @categories = {}
    Decidim::Area.all.each { |e| @categories[ e.name['pl'] ] = e }

    @units = {}
    Decidim::AdminExtended::Department.where(old_type: 'unit').each { |e| @units[e.old_id] = e }

    @offices = {}
    Decidim::AdminExtended::Department.where(old_type: 'office').each { |e| @offices[e.old_id] = e }

    @districts = {}
    Decidim::Scope.where.not(old_ids: nil).each do |district|
      district.old_ids.each do |id|
        @districts[id] = district
      end
    end
    @global_district = Decidim::Scope.find_by name: {"pl": "Ogólnomiejski"}
  end

  def call(from_index = nil)
    @import_errors = []
    read_data_from_file
    # data.first(50).each do |d|
    data.each_with_index do |d, index|
      next if from_index && index < from_index

      ap "-- " * 20
      ap "index: #{index}"
      old = OldModels::Project.new(d)
      next if Decidim::Projects::Project.find_by(old_id: old.id)

      Decidim::Projects::Project.transaction do
        process_project(old, index)
      end
    end
    ap @import_errors
    true
  end

  def process_project(old, project_index = "")
    project = nil
    published_already = false
    edition = @editions[old.taskGroupId]
    region = @regions[old.regionId] if old.regionId

    creator = find_creator(old.creatorId)
    unless creator
      error_message = "old_id: #{old.id}, y: #{edition.edition_year}, p_index: #{project_index}/X, status: #{old.status}, no history, no user old.creatorId: #{old.creatorId}"
      add_log(old, error_message, 'project-no history, no user')
      # raise Importers::NoUserImporterError.new(error_message)
      creator = create_missing_user(old.creatorId)
    end

    if old.history.none?
      project = old.build_project(edition, creator, region)
      project.scope = old.get_scope(@global_district, @districts)
      process_recipients(old, project)
      process_categories(old, project)

      Decidim.traceability.perform_action!(:create, Decidim::Projects::Project, creator, visibility: "admin-only") do
        project.save
        project
      end
    end

    old.history.each_with_index do |h, index|
      ap "History VER[#{index}], type: #{h.type}"
      # 1 – Publiczna,
      # 2 - Tylko dla administratora – niepubliczny,
      # 3 – Oczekuje na zatwierdzenie,
      # 4 – Projekt realizowany,
      # -1 – Kopia robocza
      version = h.project_version
      user = find_creator(h.userId)
      unless user
        error_message = "old_id: #{old.id}, y: #{edition.edition_year}, p_index: #{project_index}/#{index}, status: #{old.status}, brak user dla historii old_id: #{h.userId}"
        add_log(old, error_message, 'with history, no user')
        # raise Importers::NoUserImporterError.new(error_message)
        user = create_missing_user(h.userId)
      end

      if index == 0
        ap 'tworzymy projekt'
        project = version.build_project(edition, creator, region)
        project.admin_signature = "Urząd Miasta" if creator.id != user.id
        project.createTime = h.createTime # aktualizacja created_at dla wersji
        project.created_at = h.createTime
        project.updated_at = h.createTime
        project.visible_type = h.type
        project.scope = version.get_scope(@global_district, @districts)
        process_recipients(version, project)
        process_categories(version, project)

        if h.type == 1
          # publikujemy od razu
          project.published_at = h.createTime
          published_already = true
        end

        Decidim.traceability.perform_action!(:create, Decidim::Projects::Project, user, visibility: "admin-only") do
          project.save
          project
        end
        next
      end

      # publikujemy, lub aktualizujemy projekt
      version.update_project(project)
      ap "project.changes: "
      ap project.changes
      project.tmp_visible = nil # czyscimy zapisywanie wersji

      project.admin_signature = "Urząd Miasta" if creator.id != user.id
      project.createTime = h.createTime # aktualizacja created_at dla wersji
      project.updated_at = h.createTime
      project.visible_type = h.type

      process_recipients(version, project)
      process_categories(version, project)
      if version.mainRegionId.blank?
        project.scope = nil
      else
        project.scope = version.get_scope(@global_district, @districts)
      end

      if !published_already && (version.status == 4 || version.status == 3 || version.status == 2)
        ap "publikujemy!!"
        ap "publikujemy!!"
        project.published_at = DateTime.parse(h.createTime)
        published_already = true
        Decidim.traceability.perform_action!("user_publish", project, user, visibility: "all") do
          project.set_visible_version if [1, 4].include?(h.type)
          project.save
          project
        end
        next
      end

      if !published_already
        ap "jeszcze nie opublikowany"
        Decidim.traceability.perform_action!(:user_draft, project, user, visibility: "admin-only") do
          project.save
          project
        end
      else
        ap "history_type: #{h.type}"
        visibility = [1, 4].include?(h.type) ? "all" : 'admin-only'
        Decidim.traceability.perform_action!(:user_update, project, user, visibility: visibility) do
          ap "project.set_visible_version1? tmp_visible: #{[1, 4].include?(h.type).to_s}"
          project.set_visible_version if [1, 4].include?(h.type)
          project.save
          project
        end
      end
    end

    # aktualizacja projektu, nie bedzie widoczne w historii aktualizacji projektu
    ap 'ostateczna aktualizacja projektu'
    old.update_project(project)
    project.scope = old.get_scope(@global_district, @districts)
    project.visible_type = 10 # bez importowanej historii
    project.save

    process_realizations(old, project)
    process_comments(old, project)
    project

  rescue Importers::ImporterError => e
    @import_errors << e.message
  end

  def find_creator(creator_id)
    return if creator_id.blank? # moze nie byc creatora

    user = Decidim::User.where('old_id=? OR "all_old_ids"::TEXT LIKE ? OR "all_old_ids"::TEXT LIKE ? OR "all_old_ids"::TEXT LIKE ? OR "all_old_ids"::TEXT LIKE ?',
                               creator_id, "#{creator_id}",  "%,#{creator_id}", "#{creator_id},%", "%,#{creator_id},%").first
    unless user
      user = Decidim::Projects::SimpleUser.find_by old_id: creator_id
    end
    # unless user
    #   add_log(old, error_message)
    #   raise Importers::NoUserImporterError.new(error_message)
    # end
    user
  end

  def remove_projects_from_file
    # path = 'files_to_migrate/wawa-full/projects/1.json'
    # i = Importers::ProjectsImporter.new(path)
    # i.remove_projects_from_file

    read_data_from_file unless data
    1.tap do
      data.each_with_index do |d, index|
        ap "index: #{index}"
        old = OldModels::Project.new(d)
        p = Decidim::Projects::Project.find_by old_id: old.id
        p.destroy if p
      end
    end
    true
  end

  def process_recipients(version, project)
    ap 'process_recipients'
    return if version.recipients.blank?

    recip_ids = []
    version.recipients.each do |recipient_name|
      # w historycznych wersjach dane sa jako Hash
      recipient_name = recipient_name['name'] if recipient_name.is_a? Hash

      project.custom_recipients = version.recipientOther.presence
      next if recipient_name == 'inni'

      recip = @recipients[recipient_name]
      if recip
        recip_ids << recip.id
        recip_ids.sort!
        # unless project.recipient_ids.include? recip.id
        #   project.recipients << recip
        # end
      else
        project.custom_recipients = project.custom_recipients.blank? ? recipient_name : "#{project.custom_recipients}, #{recipient_name}"
      end
    end
    project.recipient_ids = recip_ids
    project.update_recipient_names
  end

  def process_categories(version, project)
    ap 'process_categories'
    return if version.categories.blank?

    cat_ids = []
    version.categories.each do |category_name|
      # w historycznych wersjach dane sa jako Hash
      category_name = category_name['name'] if category_name.is_a? Hash

      project.custom_categories = version.classificationOther.presence
      next if category_name == 'inni'

      # w starych projektach sa inne nazwy
      category_name = "komunikacja publiczna i drogi" if category_name == "komunikacja\/drogi"

      cat = @categories[category_name]
      if cat
        cat_ids << cat.id
        cat_ids.sort!
        # unless project.category_ids.include?(cat.id)
        #   project.categories << cat
        # end
      else
        project.custom_categories = project.custom_categories.blank? ? category_name : "#{project.custom_categories}, #{category_name}"
      end
    end
    project.category_ids = cat_ids
    project.update_category_names
  end

  def process_comments(old, project)
    old.comments.each_with_index do |c, index|
      creator = find_creator(c.creatorId)
      unless creator
        creator = create_missing_user(c.creatorId)
        add_log(old, "no-user-in-process_comments, user_id: #{c.creatorId}", 'no-user-in-process_comments')
        # raise Importers::NoUserImporterError.new("no-user-in-process_comments, user_id: #{c.creatorId}")
      end
      c.create_comment(project, creator)
    end
  end

  def process_realizations(old, project)
    return if old.realization.blank? || old.realization.history.none?

    project.update_column(:producer_list, old.realization.realizedBy) if old.realization.realizedBy.present?

    old.realization.history.each do |h|
      i = project.implementations.new
      i.update_data = {}
      i.update_data['factual_budget_value'] = h.costVerified
      i.update_data['implementation_on_main_site'] = old.realization.displayHomepage
      i.update_data['producer_list'] = h.realizedBy
      # update_data: {"photos": {},
      # "producer_list": "Wydział Ochrony Środowiska",
      # "factual_budget_value": 123,
      # "implementation_status": "5",
      # "implementation_on_main_site": true,
      # "implementation_on_main_site_slider": true
      # }
      i.body = h.realizationDescription
      i.implementation_date = h.modifiedRealization
      i.created_at = h.createTime
      user = find_creator(h.userId)
      if user
        i.user_id = user.id
      else
        add_log(old, "no-user-in-process_realizations, user_id: #{h.userId}", 'process_realizations')
      end

      i.save
    end
  end

  def reset_table
    Decidim::Projects::ImportLog.where(resource_type: "OldModels::Project").delete_all

    Decidim::Attachment.destroy_all
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."versions" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."project_versions" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_project_areas" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_project_recipients" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_implementations" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_appeals" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_coauthorships" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_projects" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_reports" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_moderations" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_comments_comments" RESTART IDENTITY CASCADE;')

    Decidim::SearchableResource.where(resource_type: "Decidim::Comments::Comment").delete_all
    Decidim::SearchableResource.where(resource_type: "Decidim::Projects::Project").delete_all

    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_evaluations" RESTART IDENTITY CASCADE;')
  end

  def reset_all
    PaperTrail.request(enabled: false) do
      Decidim::ActionLog.where(resource_type: 'Decidim::Projects::Project').delete_all
      Decidim::Coauthorship.where(coauthorable_type: 'Decidim::Projects::Project').destroy_all
      Decidim::Coauthorship.where(coauthorable_type: 'Decidim::Projects::Comment').destroy_all
      Decidim::Coauthorship.where(coauthorable_type: 'Decidim::Proposals::Proposal').destroy_all
      Decidim::Moderation.destroy_all
      Decidim::Comments::Comment.delete_all
      Decidim::Projects::Project.destroy_all
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE versions CASCADE;")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE project_versions CASCADE;")
      ActiveRecord::Base.connection.execute("SELECT setval('versions_id_seq', max(id)) FROM versions;")
      ActiveRecord::Base.connection.execute("SELECT setval('project_versions_id_seq', max(id)) FROM versions;")
    end
  end

  def old_model
    OldModels::Cocreator
  end

  def import_all_attachments(from_index = nil)
    read_data_from_file if data.nil?
    data.each_with_index do |d, index|
      next if from_index && index < from_index

      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d) # /uploads/tasks/1576499430_zalacznik_0_143_21954.jpg
      import_attachments(old)
    end
    true
  end

  def import_attachments(old_project)
    project = Decidim::Projects::Project.find_by old_id: old_project.id
    return unless project
    return if project.files.any?

    project.attachment_context_for_import = :migration
    # /uploads/tasks/1576499430_zalacznik_0_143_21954.jpg
    old_project.attachments.each do |a|
      url = a.url
      file_name = a.originalName
      file_path = "#{import_root_path}#{url}"
      unless File.file?(file_path)
        add_log(old_project, 'file-no-attachment', file_path)
        next
      end
      File.open(file_path) do |file|
        attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
        project.files << Decidim::Projects::VariousFile.new(attachment_attrs)
      end
    end
    project
  end

  def import_attachment(old_attachment, project)
    project.attachment_context_for_import = :migration
    url = old_attachment.url
    file_name = old_attachment.originalName
    file_path = "#{import_root_path}#{url}"

    File.open(file_path) do |file|
      attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
      vf = Decidim::Projects::VariousFile.new(attachment_attrs)
      vf.valid?

      project.files << vf
    end
  end

  def import_all_verifications
    user = Decidim::User.first
    read_data_from_file if data.nil?
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      project = Decidim::Projects::Project.find_by old_id: old.id
      next unless project

      Decidim::Projects::Project.transaction do
        import_verification(old, project, user)
      end
    end
    true
  end

  def import_verification(old, project, user)
    if old.verification.formalResult.present?
      evaluation = project.formal_evaluation.presence || project.create_formal_evaluation(user: user, details: old.verification.formal_result_details)
      evaluation.update_column :details, old.verification.formal_result_details # for fix migration only

      if evaluation.documents.size != old.verification.formal_attachments.size
        evaluation.documents.destroy_all # for fix migration only
        add_attachments_to_evaluation(old, old.verification.formal_attachments, evaluation)
      end
    end

    if old.verification.meritResult.present?
      evaluation = project.meritorical_evaluation.presence || project.create_meritorical_evaluation(user: user, details: old.verification.merit_result_details)
      evaluation.update_column :details, old.verification.merit_result_details # for fix migration only

      if evaluation.documents.size != old.verification.merit_attachments.size
        evaluation.documents.destroy_all # for fix migration only
        add_attachments_to_evaluation(old, old.verification.merit_attachments, evaluation)
      end
    end

    if old.verification.reevaluationResult.present? || old.verification.reevaluation_attachments.any?
      details = old.verification.reevaluation_result_details.presence || old.verification.merit_result_details
      evaluation = project.reevaluation.presence || project.create_reevaluation(user: user, details: details)
      evaluation.update_column :details, old.verification.reevaluation_result_details # for fix migration only

      if evaluation.documents.size != old.verification.reevaluation_attachments.size
        evaluation.documents.destroy_all # for fix migration only
        add_attachments_to_evaluation(old, old.verification.reevaluation_attachments, evaluation)
      end
    end
  end

  def add_attachments_to_evaluation(old_project, attachments, evaluation)
    return if Rails.env.development?

    attachments.each do |file_name|
      file_path = "#{import_root_path}/uploads/verifications/#{file_name}"
      unless File.file?(file_path)
        add_log(old_project, 'file-no-verification', file_path)
        next
      end
      File.open(file_path) do |file|
        attachment_attrs = { title: { I18n.locale => file_name }, attached_to: evaluation, file: file }
        evaluation.documents << Decidim::Attachment.new(attachment_attrs) # No such file or directory /var/www/decidim/migracja/uploads/tasks/verifications/14629653750388.pdf
      end
    end
  end

  def import_realizations
    read_data_from_file
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      next if old.realization.blank?

      import_realization(old)
    end

    true
  end

  def import_realization(old)
    project = Decidim::Projects::Project.find_by old_id: old.id
    return unless project
    return if project.implementation_photos.any?

    project.attachment_context_for_import = :admin
    old.realization.image.each do |img|
      file_name = img['fileName']
      file_path = "#{import_root_path}/uploads/archive/images/#{file_name}"
      unless File.file?(file_path)
        add_log(old, 'file-no-realization', file_path)
        next
      end

      photo = project.implementation_photos.create(
        image_alt: img['alt'],
        main_attachment: img['isMainImg'] == "1"
      )
      File.open(file_path) do |file|
        photo.file.attach(io: file, filename: file_name)
      end
    end
  end

  def import_private_files
    read_data_from_file
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      next if old.privateFiles.none?

      project = Decidim::Projects::Project.find_by old_id: old.id
      next unless project
      next if project.internal_documents.any?

      old.privateFiles.each do |private_file|
        file_name = private_file.fileName
        file_path = "#{import_root_path}/uploads/privateAttachments/#{file_name}"
        original_name = private_file.originalName
        unless File.file?(file_path)
          add_log(old, 'file-no-internal-document', file_path)
          next
        end

        File.open(file_path) do |file|
          attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
          project.internal_documents << Decidim::Projects::InternalDocument.new(attachment_attrs)
        end
      end
    end

    true
  end

  def import_creator_agreements
    read_data_from_file
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      next if old.creatorAgreementFiles.none?

      project = Decidim::Projects::Project.find_by old_id: old.id
      next unless project
      next if project.consents.any?

      project.attachment_context_for_import = :admin
      old.creatorAgreementFiles.each do |agreement|
        file_name = agreement['fileName']
        file_path = "#{import_root_path}/uploads/tasks/#{file_name}"
        unless File.file?(file_path)
          add_log(old, 'file-no-creator_agreements', file_path)
          next
        end

        File.open(file_path) do |file|
          attachment_attrs = { title: { I18n.locale => file_name }, attached_to: project, file: file }
          project.consents << Decidim::Projects::Consent.new(attachment_attrs)
        end
      end
    end

    true
  end

  def import_verification_recalls
    read_data_from_file
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      next if old.taskVerificationRecall.createTime.nil?

      project = Decidim::Projects::Project.find_by old_id: old.id
      next unless project
      next if project.appeal

      appeal = Decidim::Projects::Appeal.new(
        project: project,
        body: old.taskVerificationRecall.content,
        time_of_submit: old.taskVerificationRecall.createTime,
        # default
        evaluator: nil,
        is_paper: true
      )
      appeal.save!
      old.taskVerificationRecall.attachments.each do |attachment|
        file_name = attachment['fileName']
        file_path = "#{import_root_path}/uploads/recall/#{file_name}"
        unless File.file?(file_path)
          add_log(old, 'file-no-recall', file_path)
          next
        end

        File.open(file_path) do |file|
          attachment_attrs = { title: { I18n.locale => file_name }, attached_to: appeal, file: file }
          appeal.attachments << Decidim::Attachment.new(attachment_attrs)
        end
      end
    end

    true
  end

  def import_all_cocreators
    [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
      path = "task-list-last/task-list-v1-editions-#{year}.json"
      i = Importers::ProjectsImporter.new path
      i.read_data_from_file
      Decidim::Projects::Project.transaction do
        i.import_cocreators
      end
    end
  end

  def import_cocreators
    ci = Importers::CocreatorsImporter.new
    ci.read_data_from_file
    missing = []

    read_data_from_file if data.nil? || data&.none?
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      next if old.cocreators.none?

      project = Decidim::Projects::Project.find_by old_id: old.id
      old.cocreators.each do |cocreator_id|
        old_cocreator = ci.find_old(cocreator_id)
        user_id = old_cocreator.userId

        creator = find_creator(user_id)
        unless creator
          missing << old.id
          error_message = "old_id: #{old.id}, p_index: #{index}/X, status: #{old.status}, no cocreator: #{user_id}"
          add_log(old, error_message, 'no cocreator')
          creator = create_missing_user(user_id)
        end
        project.add_coauthor(creator, confirmation_status: 'confirmed', coauthorship_acceptance_date: Date.current, coauthor: true)
      end
    end
    ap missing
    true
  end

  def fix_locations
    problems = []
    data.each_with_index do |d, index|
      ap "index: #{index}, old_id: #{d['id']}"
      old = OldModels::Project.new(d)
      project = Decidim::Projects::Project.find_by old_id: old.id
      next unless project

      if project.locations.size != old.mapPins.size
        project.update_column :locations, old.get_locations
        problems << project.id
      end
    end
    ap problems
    true
  end

  def fix_all_locations
    [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023].each do |year|
      ap "year: #{year}"
      path = "task-list-last/task-list-v1-editions-#{year}.json"
      i = Importers::ProjectsImporter.new path
      i.read_data_from_file
      i.fix_locations
    end
  end

  def test_number_of_locations
    year = 2021
    path = "task-list-last/task-list-v1-editions-#{year}.json"
    i = Importers::ProjectsImporter.new path
    i.read_data_from_file

    scope = Decidim::Scope.find 34 # Wesola
    scope.old_ids
    size = 0

    projects = []
    1.tap do
      i.data.each_with_index do |d, index|
        ap "index: #{index}, old_id: #{d['id']}"
        old = OldModels::Project.new(d)
        if old.mainRegionId && scope.old_ids.include?(old.mainRegionId) && (old.status >= 2 || old.status == -3 || old.status == -2 || old.status == -1)
          size += old.mapPins.size
          projects << old
        end
      end
    end
  end

  def test_file_xxxx
    i = Importers::ProjectsImporter.new nil, "task-list-last/task-list-v1-editions-2022.json"
    i.read_data_from_file
    d = i.data[2457]
    old = OldModels::Project.new(d)
    old.taskVerificationRecall
    old.privateFiles
  end
end
