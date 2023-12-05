# frozen_string_literal: true

RSpec.shared_context 'with projects component' do
  let!(:projects_component) do
    create(
      :component,
      manifest_name: :projects,
      participatory_space: part_process,
      name: {
        pl: 'Projekty'
      },
      settings: {
        announcement: {
          en: nil,
          pl: ''
        }
      },
      step_settings: {
        part_process_step_0.id.to_s => {
          creation_enabled: true,
          voting_enabled: true,
          announcement: {},
          announcement_en: nil,
          announcement_pl: nil
        }
      }
    )
  end

  let!(:customization_project) do
    create(
      :projects_project_customization,
      process: part_process,
      custom_names: load_fixture_yaml('projects_project_customization.yml')[:pc_1][:custom_names]
    )
  end
end
