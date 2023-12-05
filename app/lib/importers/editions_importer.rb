# frozen_string_literal: true

class Importers::EditionsImporter < Importers::BaseImporter

  def initialize(path='dictionary-editions-list-v1.json')
    @file_path = "#{import_root_path}/#{path}"
  end

  # Importers::EditionsImporter.new.call
  def call
    read_data_from_file
    process_file_data
    true
  end

  def process_file_data
    organization = Decidim::Organization.first

    data.each do |d|
      item = OldModels::Edition.new(d)
      # Decidim::AdminExtended::Recipient.create(id: item.id, name: item.name)

      create_participatory_process(item, organization)
    end
    true
  end

  def remove_all_data
    Decidim::Attachment.destroy_all
    Decidim::Projects::ProjectUserAssignment.destroy_all
    Decidim::Projects::ProjectDepartmentAssignment.destroy_all
    Decidim::Projects::Project.destroy_all
    Decidim::ParticipatoryProcess.destroy_all
    reset_table
    reset_index
  end


  def ttt
    i = Importers::EditionsImporter.new
    i.read_data_from_file
    organization = Decidim::Organization.first
    item = OldModels::Edition.new(i.data.first)
    p = i.create_participatory_process(item, organization)
  end

  def create_participatory_process(item, organization)
    process = Decidim::ParticipatoryProcess.new(
      # id: item.id,
      old_id: item.id,
      organization: organization,
      title: { pl: item.name },
      subtitle: { pl: item.name },
      weight: 0,
      slug: item.name.parameterize,
      hashtag: nil,
      description: { pl: item.name },
      short_description: { pl: item.name },
      hero_image: nil,
      banner_image: nil,
      promoted: false,
      scopes_enabled: false,

      scope: nil,
      scope_type_max_depth: nil,
      private_space: false,
      developer_group: { pl:"" },
      local_area: { pl:"" },
      area: nil,
      target: { pl:"" },
      participatory_scope: { pl:"" },
      participatory_structure: { pl:"" },
      meta_scope: { pl:"" },
      start_date: Date.new(item.year, 1, 12),
      end_date: Date.new(item.year + 1, 1, 12),
      published_at: Date.new(item.year, 1, 12), # publikacja
      participatory_process_group: nil,
      edition_year: item.year,
      # special dates
      project_editing_end_date: nil,
      withdrawn_end_date: nil,
      evaluation_start_date: nil,
      evaluation_end_date: nil,
      evaluation_publish_date: nil,
      appeal_start_date: DateTime.new(item.year + 1, 5, 4, 10, 20, 00, "+01:00"), # 04.05.2022 10:20:00 +01:00 — 31.05.2022 10:20:00 +01:00
      appeal_end_date: DateTime.new(item.year + 1, 5, 31, 10, 20, 00, "+01:00"),
      reevaluation_publish_date: nil,
      paper_project_submit_end_date: Date.new(item.year + 1, 1, 25),
      evaluation_cards_submit_end_date: nil,
      paper_voting_submit_end_date: Date.new(item.year + 1, 7, 13),
      status_change_notifications_sending_end_date: nil
    )
    raise "ERROR!" unless process.valid?

    process.save!
    create_project_component(organization, process, Decidim::User.first)
    create_default_scope_budgets(process)

    process
  end


  def create_project_component(organization, process, user)
    Decidim::ParticipatoryProcess::DEFAULT_STEPS_SYSTEM_NAMES.each do |name|
      process.steps.create!(
        system_name: name,
        title: Decidim::TranslationsHelper.multi_translation(
          name,
          organization.available_locales,
          scope: "decidim.admin.participatory_process_steps.step_title"
        ),
        active: name == :submitting,
        start_date: name == :submitting ? Date.new(process.edition_year, 12, 1) : nil,
        end_date: name == :submitting ? Date.new(process.edition_year + 1, 1, 25) : nil,
      )
    end

    manifest = Decidim.find_component_manifest('projects')
    new_settings = proc { |name, data| Decidim::Component.build_settings(manifest, name, data, organization) }
    hsh = {}
    hsh[:settings] = new_settings.call(:global, {})
    hsh[:step_settings] = {}
    process.steps.each_with_index do |step, index|
      hsh[:step_settings][step.id.to_s] = new_settings.call(:step, {
        creation_enabled: index == 0,
        voting_enabled: index == 2
      })
    end
    params = {
      name: { pl: 'Projekty' },
      manifest: manifest,
      participatory_space: process,
      settings: hsh[:settings],
      step_settings: hsh[:step_settings]
    }
    ff = Decidim::Admin::ComponentForm.from_params(params).with_context({
                                                                          current_organization: organization,
                                                                          # current_component: @controller.try(:current_component),
                                                                          current_user: user,
                                                                          current_participatory_space: process
                                                                        })
    Decidim::Admin::CreateComponent.call(ff)
  end

  def create_default_scope_budgets(process)
    current_organization = Decidim::Organization.first
    current_organization.scopes.top_level.active.each do |scope|
      Decidim::ProcessesExtended::ScopeBudget.create(
        scope: scope,
        participatory_process: process,
        budget_value: 10000,
        max_proposal_budget_value: 10000)
    end
  end

  # Dla wszystkich wczesniej wygenerowanych procesow
  def create_all_default_scope_budgets
    Decidim::ParticipatoryProcess.all.each do |process|
      next if Decidim::ProcessesExtended::ScopeBudget.where(decidim_participatory_process_id: process.id).any?

      create_default_scope_budgets(process)
    end

    true
  end

  # private

  def reset_table
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_participatory_processes" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_participatory_process_steps" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_components" RESTART IDENTITY CASCADE;')
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_participatory_processes_id_seq', max(id)) FROM decidim_participatory_processes;")
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_participatory_process_steps_id_seq', max(id)) FROM decidim_participatory_process_steps;")
  end
end
