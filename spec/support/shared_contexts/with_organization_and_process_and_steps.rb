# frozen_string_literal: true

RSpec.shared_context 'with organization and process and steps' do
  let!(:organization) do
    create(
      :organization,
      default_locale: :pl,
      available_locales: [:pl],
      cta_button_text: { "pl": 'ZGŁOŚ PROJEKT' },
      cta_button_path: '',
      enable_omnipresent_banner: true,
      send_welcome_notification: false,
      time_zone: 'Warsaw',
      host: 'localhost',
      file_upload_settings: { 'maximum_file_size' => { 'avatar' => 5.0, 'default' => 20.0 } }
    )
  end

  let!(:part_process) do
    create(
      :participatory_process,
      organization: organization,
      slug: 'testowy-proces-1',
      title: { "pl": 'Testowy Proces 1 title' },
      subtitle: { "pl": 'Testowy Proces 1 subtitle' },
      start_date: '2022-11-13', # data rozpoczęcia
      end_date: '2023-07-13', # data zakończenia
      project_editing_end_date: '2023-01-25', # do kiedy użytownicy mogą edytować swoje projekty?
      paper_project_submit_end_date: '2023-02-02', # do kiedy użytkownicy wewnętrzni mogą wprowadzać wersje papierowe projektów?
      withdrawn_end_date: '2023-06-01', # do kiedy użytkownicy mogą wycofywać projekty?
      evaluation_start_date: '2023-01-26', # od kiedy koordynatorzy mogą przypisywać projekty do oceny?
      evaluation_cards_submit_end_date: '2023-05-04T10:59:00.000+02:00', # do kiedy weryfikatorzy mogą oceniać projekty?
      evaluation_end_date: '2023-05-12T10:00:00.000+02:00', # Do kiedy koordynatorzy muszą zatwierdzić oceny?
      evaluation_publish_date: '2023-05-04T11:00:00.000+02:00', # Data publikacji ocen
      appeal_start_date: '2023-05-04T11:05:00.000+02:00', # Od kiedy użytkownicy mogą składać odwołania?
      appeal_end_date: '2023-05-11T23:59:00.000+02:00', # Do kiedy użytkownicy mogą składać odwołania?
      reevaluation_publish_date: '2023-05-31T16:00:00.000+02:00', # Data i godzina publikacji wyników ponownej oceny
      status_change_notifications_sending_end_date: '2023-05-31', # Do kiedy można wysyłać powiadomienia o zmianie statusu projektu?
      paper_voting_submit_end_date: '2023-07-12', # Do kiedy użytkownicy wewnętrzni mogą wprowadzać wersje papierowe kart do głosowania?
      published_at: '2022-10-10T08:00:00.000+02:00',
      weight: 0,
      edition_year: 2024,
      show_voting_results_button_at: '2022-10-10T08:00:00.000+02:00'
    )
  end

  let!(:part_process_step_0) do
    create(
      :participatory_process_step,
      participatory_process: part_process,
      title: { "pl": 'Zgłaszanie projektów' },
      description: { "pl": '' },
      start_date: '2022-12-13',
      end_date: '2023-01-16',
      active: true,
      position: 0,
      cta_text: { "pl": '' },
      cta_path: '',
      system_name: 'submitting'
    )
  end
end
