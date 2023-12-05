# frozen_string_literal: true

module Decidim
  module Projects
    # This class serializes a Vote so can be exported to CSV, JSON or other
    # formats.
    class VoteCardAnonymousSerializer < Decidim::Projects::VoteCardSerializer

      # Public: Exports a hash with the serialized data for this vote.
      def serialize
        {
          id: vote_card.id,
          ip_number: "*",
          card_number: vote_card.card_number,
          created_at: I18n.l(vote_card.created_at, format: :decidim_short), # 'Data utworzenia',
          d: vote_card.activated_at.nil? ? "-" : I18n.l(vote_card.activated_at, format: :decidim_long),
          d2: vote_card.submitted_at.nil? ? "-" : I18n.l(vote_card.submitted_at, format: :decidim_long),
          first_name: "*",     # 'Imię',
          last_name:  "*",       # 'Nazwisko',
          pesel_number:  "*", # 'Nr PESEL',
          sex: I18n.t(vote_card.gender, scope: 'decidim.projects.admin.votes_cards.show', default: nil), # 'Płeć',
          age: vote_card.age,                   # 'Wiek',
          age_0_3: vote_card.age_in(0, 3),      # 'Wiek 0-3',
          age_4_6: vote_card.age_in(4, 6),      # 'Wiek 4-6',
          age_7_10: vote_card.age_in(7, 10),    # 'Wiek 7-10',
          age_11_14: vote_card.age_in(11, 14),  # 'Wiek 11-14',
          age_15_18: vote_card.age_in(15, 18),  # 'Wiek 15-18',
          age_19_24: vote_card.age_in(19, 24),  # 'Wiek 19-24',
          age_25_34: vote_card.age_in(25, 34),  # 'Wiek 25-34',
          age_35_44: vote_card.age_in(35, 44),  # 'Wiek 35-44',
          age_45_64: vote_card.age_in(45, 64),  # 'Wiek 45-64',
          age_65_79: vote_card.age_in(65, 79),  # 'Wiek 65-79',
          age_80: vote_card.age_in(80, 150),    # 'Wiek 80+',
          age_missing: vote_card.age.blank? ? 'Tak' : nil, #           'Wiek b.d.'
          city: "*", #             'Miejscowość',
          street: "*", # 'Adres zamieszkania - ulica',
          street_number: "*", #           'Adres zamieszkania - nr domu',
          flat_number: "*", # 'Adres zamieszkania - nr lokalu',
          zip_code: "*",       # 'Adres zamieszkania - kod pocztowy',
          email: "*",             # 'Adres e-mail',
          submitting_method: vote_card.submitting_method, # 'Sposób głosowania',
          status: vote_status(vote_card), # 'Status karty do głosowania',
          # error_global_projects_count_exceeded: '',             # 'Błąd: liczba projektów ogólnomiejskich ponad limit',
          # error_district_projects_count_exceeded: '',           # 'Błąd: liczba projektów dzielnicowych ponad limit',
          # error_pesel_number_blank: '',                         # 'Błąd: brak nr PESEL',
          # error_pesel_number_invalid: '',                       # 'Błąd: błędny nr PESEL',
          # error_card_not_signed: '',                            # 'Błąd: brak podpisu',
          # error_identity_not_checked: '',                       # 'Błąd: tożsamość niepotwierdzona',
          # error_pesel_used: '',                                 # 'Błąd: karta oddana wielokrotnie na te same dane',
          # error_empty_projects: '',                             # 'Błąd: brak wybranych projektów',
          # error_card_received_late: '',                         # 'Błąd: karta oddana poza terminem głosowania',
          # error_unreadable: '',                                 # 'Błąd: dane nieczytelne',
          # error_invalid_card: '',                               # 'Błąd: niepoprawna karta',
          scope: vote_card.scope ? translated_attribute(vote_card.scope.name) : nil, # 'Dzielnica',
          projects_count: vote_card.global_projects_count + vote_card.district_projects_count, # 'Liczba wybranych projektów',
          global_projects_count: vote_card.global_projects_count,                              # 'Liczba wybranych projektów ogólnomiejskich',
          district_projects_count: vote_card.district_projects_count,                          # 'Liczba wybranych projektów dzielnicowych',
          c1: vote_card.verification_results['projects_cost'],             # 'Łączny koszt',
          c2: vote_card.verification_results['global_projects_cost'],      # 'Koszt projektów ogólomiejskich',
          c3: vote_card.verification_results['district_projects_cost'],    # 'Koszt projektów dzielnicowych',
          c4: vote_card.verification_results['global_projects_numbers'],   # 'Numery projektów ogólnomiejskich',
          c5: vote_card.verification_results['district_projects_numbers'],   # 'Numery projektów dzielnicowych',
          c6: vote_card.verification_results['global_projects_cost_list'],   # 'Koszty projektów ogólnomiejskich',
          c7: vote_card.verification_results['district_projects_costs_list'], # 'Koszty projektów dzielnicowych',
          c8: "*", # 'Imię z bazy do weryfikacji',
          c9: "*" # 'Nazwisko z bazy do weryfikacji',
          # c10: '' # 'Które dane nieprawidłowe'

        }
      end

    end
  end
end
