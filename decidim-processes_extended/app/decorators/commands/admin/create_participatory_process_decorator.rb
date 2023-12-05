# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do
  private

  # overwritten method
  # clear method's content for overwrite default admin connect
  def add_admins_as_followers(process); end

  # overwritten method
  # after create process create also project component and default scope budgets
  # added custom attributes
  def create_participatory_process
    @process = Decidim::ParticipatoryProcess.new(
      organization: form.current_organization,
      title: form.title,
      subtitle: form.subtitle,
      weight: form.weight,
      slug: form.slug,
      hashtag: form.hashtag,
      description: form.description,
      short_description: form.short_description,
      hero_image: form.hero_image,
      banner_image: form.banner_image,
      promoted: form.promoted,
      scopes_enabled: form.scopes_enabled,
      scope: form.scope,
      scope_type_max_depth: form.scope_type_max_depth,
      private_space: form.private_space,
      developer_group: form.developer_group,
      local_area: form.local_area,
      area: form.area,
      target: form.target,
      participatory_scope: form.participatory_scope,
      participatory_structure: form.participatory_structure,
      meta_scope: form.meta_scope,
      start_date: form.start_date,
      end_date: form.end_date,
      participatory_process_group: form.participatory_process_group,
      # custom - edition_year
      edition_year: form.edition_year,
      # custom - special dates
      project_editing_end_date: form.project_editing_end_date,
      withdrawn_end_date: form.withdrawn_end_date,
      evaluation_start_date: form.evaluation_start_date,
      evaluation_end_date: form.evaluation_end_date,
      evaluation_publish_date: form.evaluation_publish_date,
      appeal_start_date: form.appeal_start_date,
      appeal_end_date: form.appeal_end_date,
      reevaluation_cards_submit_end_date: form.reevaluation_cards_submit_end_date,
      reevaluation_end_date: form.reevaluation_end_date,
      reevaluation_publish_date: form.reevaluation_publish_date,
      paper_project_submit_end_date: form.paper_project_submit_end_date,
      evaluation_cards_submit_end_date: form.evaluation_cards_submit_end_date,
      paper_voting_submit_end_date: form.paper_voting_submit_end_date,
      status_change_notifications_sending_end_date: form.status_change_notifications_sending_end_date,
      show_start_voting_button_at: form.show_start_voting_button_at,
      show_voting_results_button_at: form.show_voting_results_button_at,
      # custom - values for voting validations
      global_scope_projects_voting_limit: form.global_scope_projects_voting_limit,
      district_scope_projects_voting_limit: form.district_scope_projects_voting_limit,
      minimum_global_scope_projects_votes: form.minimum_global_scope_projects_votes,
      minimum_district_scope_projects_votes: form.minimum_district_scope_projects_votes
    )

    return process unless process.valid?

    transaction do
      process.save!

      log_process_creation(process)

      Decidim::ParticipatoryProcess::DEFAULT_STEPS_SYSTEM_NAMES.each do |name|
        process.steps.create!(
          system_name: name,
          title: Decidim::TranslationsHelper.multi_translation(
            name,
            form.current_organization.available_locales,
            scope: 'decidim.admin.participatory_process_steps.step_title'
          ),
          active: false
        )
      end
      create_settings_for_endorsement_list(process)
      create_project_component(form.current_organization, process, form.current_user)
      create_default_scope_budgets(form.current_organization, process)

      process
    end
  end

  def create_project_component(current_organization, process, current_user)
    manifest = Decidim.find_component_manifest('projects')
    new_settings = proc { |name, data| Decidim::Component.build_settings(manifest, name, data, current_organization) }

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
      name: Decidim::TranslationsHelper.multi_translation(
        'decidim.components.projects.name',
        current_organization.available_locales
      ),
      manifest: manifest,
      participatory_space: process,
      settings: hsh[:settings],
      step_settings: hsh[:step_settings]
    }

    ff = Decidim::Admin::ComponentForm.from_params(params).with_context({
                                                                          current_organization: current_organization,
                                                                          # current_component: @controller.try(:current_component),
                                                                          current_user: current_user,
                                                                          current_participatory_space: process
                                                                        })
    Decidim::Admin::CreateComponent.call(ff)
  end

  def create_default_scope_budgets(current_organization, process)
    current_organization.scopes.top_level.active.each do |scope|
      Decidim::ProcessesExtended::ScopeBudget.create(scope: scope, participatory_process: process)
    end
  end

  def create_settings_for_endorsement_list(process)
    # On server relase path not working properly to set rails root path
    file_path = File.join(Rails.public_path, ApplicationController.helpers.asset_path('logo.png'))
    endorsement_list = Decidim::ProcessesExtended::EndorsementListSetting.create!(decidim_participatory_process_id: process.id,
                                                                                  header_description: ' Lista poparcia dla projektu<br />do budżetu obywatelskiego w m.st. Warszawie na rok %{process_year}',
                                                                                  footer_description: '<p><strong>Objaśnienia:</strong></p>
          <p>Lista powinna zawierać:</p> <ol><li>w przypadku projektów na poziomie dzielnicowym,<strong>podpisy co najmniej 20 mieszkańców dzielnicy m.st.Warszawy, w
          której zgłaszany jest projekt</strong> lub</li><li>w przypadku projektów na poziomie ogólnomiejskim,
          <strong>podpisy co najmniej 40 mieszkańców m.st.Warszawy</strong>popierających projekt do budżetu obywatelskiego.
          </li></ol><p>Do liczby mieszkańców popierających projekt nie wlicza się projektodawców danego projektu</p>')
    File.open(file_path) do |file|
      endorsement_list.image_header.attach(io: file, filename: "logo.png")
    end
  end
end
