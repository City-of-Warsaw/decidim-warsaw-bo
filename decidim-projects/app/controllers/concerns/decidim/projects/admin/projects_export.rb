# frozen_string_literal: true

require 'active_support/concern'

module Decidim
  module Projects
    module Admin
      # This ProjectsExport contains logic for projects export in admin panel
      module ProjectsExport
        extend ActiveSupport::Concern

        included do
          helper_method :projects_export_headers, :add_project_row,
                        :full_projects_export_headers, :add_full_project_row,
                        :authors_export_header

          private

          def all_categories
            @all_categories ||= Decidim::Area.all.pluck(:id, :name).each_with_object({}) do |el, arr|
              arr[el[0].to_s] = el[1]['pl']
            end
          end

          def category_names
            all_categories.values
          end

          def category_ids
            all_categories.keys.map(&:to_i)
          end

          def all_recipients
            @all_recipients ||= Decidim::AdminExtended::Recipient.all.pluck(:id, :name).each_with_object({}) do |el, arr|
              arr[el[0].to_s] = el[1]
            end
          end

          def recipient_names
            all_recipients.values
          end

          def recipient_ids
            all_recipients.keys.map(&:to_i)
          end

          def projects_export_headers
            [
              'Numer na liście rankingowej po losowaniu',
              'Numer projektu',
              'Sposób złożenia',
              'Data i czas złożenia',
              'Tytuł',
              'Numer ID konta użytkownik zalogowany',
              'Informacja o współautorach (TAK/NIE)',
              'Numery ID użytkownika współautorów',
              'Liczba współautorów',
              'Krótki opis',
              'Poziom',
              'Dzielnica',
              'Obszar',
              'Lokalizacja',
              'Istotne informacje o lokalizacji'
            ] + category_names + recipient_names + [
              'Zasady korzystania z efektu realizacji projektu',
              'Pełny opis projektu',
              'Uzasadnienie dla realizacji projektu',
              'Wstępny kosztorys projektu wraz z wyszczególnieniem jego składowych',
              'Szacunkowy podział kosztów między realizatorów (pole nie jest widoczne dla mieszkańców)',
              'Koszt',
              'Jednostka odpowiadająca za realizację',
              'Czy projekt generuje koszty utrzymania w kolejnych latach? (TAK/NIE)',
              'Rodzaj oraz szacunkowa wysokość kosztów eksploatacji efektu realizacji projektu w kolejnych latach',
              'Szacunkowy roczny koszt eksploatacji',
              'Status',

              # 12
              'Dane przypisanych użytkowników (nazwa oraz kontakt)',

              'Aktualna komórka',

              'Przypisany podkoordynator',
              'Adres e-mail podkoordynatora',
              'Nazwa wyświetlana podkoordynatora',

              'Przypisany weryfikator',
              'Adres e-mail weryfikatora',
              'Nazwa wyświetlana weryfikatora',

              'Wynik oceny formalnej',
              'Powód negatywnej oceny formalnej',
              'Wynik oceny merytorycznej',
              'Wynik ponownej oceny',
              'Skutki realizacji',
              'Przyczyna oceny negatywnej',
              'Data odwołania',
              'Treść odwołania',
              'Karta oceny formalnej – skan (TAK/NIE)',
              'Karta oceny formalnej – dostępna (TAK/NIE)',
              'Karta oceny merytorycznej – skan (TAK/NIE)',
              'Karta oceny merytorycznej – dostępna (TAK/NIE)',
              'Karta ponownej oceny – skan (TAK/NIE)',
              'Karta ponownej oceny – dostępna (TAK/NIE)',
              'Uwagi wprowadzającego projekt papierowy',
              'Uwagi oceny formalnej',
              'Uwagi oceny merytorycznej',
              'Dodatkowe informacje (ocena merytoryczna)',
              'Podmiot dokonujący oceny merytorycznej', # meritorical_evaluation.details["unit_name"]
              'Imię i nazwisko pracownika oceniającego merytorycznie', # meritorical_evaluation.details["verifier_name"]
              'Imię i nazwisko osoby dokonującej ponowną ocenę',
              'Zgoda na wykorzystanie utworu (TAK/NIE)',
              'Liczba głosów ważnych',
              'Link do karty projektu w module przeglądania projektów',
              'Data powiadomienia o publikacji wyników oceny',
              'Autor powiadomienia o publikacji wyników oceny'
            ]
          end

          def full_projects_export_headers
            author_header +
              coauthor_header(1) +
              coauthor_header(2) +
              projects_export_headers
          end

          def author_header
            [
              'Imię',
              'Nazwisko',
              'Płeć',
              'E-mail',
              'Telefon',
              'Ulica',
              'Numer domu',
              'Numer mieszkania',
              'Miasto',
              'Kod pocztowy'
            ]
          end

          def coauthor_header(number)
            [
              "Imię współautora #{number}",
              "Nazwisko współautora #{number}",
              "Płeć współautora #{number}",
              "E-mail współautora #{number}",
              "Telefon współautora #{number}",
              "Ulica współautora #{number}",
              "Numer domu współautora #{number}",
              "Numer mieszkania współautora #{number}",
              "Miasto współautora #{number}",
              "Kod pocztowy współautora #{number}"
            ]
          end

          def authors_export_header
            [
              'Lp.',
              'Numer użytkownika (ID)',
              'Nazwę użytkownika',
              'Imię',
              'Nazwisko',
              'Płeć',
              'E-mail',
              'Telefon',
              'Ulica',
              'Numer domu',
              'Numer mieszkania',
              'Miasto',
              'Kod pocztowy',
              'Zgoda na publikację imienia i nazwiska (TAK/NIE)',
              'Chcę otrzymywać powiadomienia na mój adres e-mail o aktualizacji stanu realizacji moich projektów.',
              'Wyrażam zgodę na otrzymywanie informacji mailowo lub telefonicznie',
              'Wyrażam zgodę na otrzymywanie wiadomości prywatnych od innych zalogowanych użytkowników',
              I18n.t('activemodel.attributes.user.inform_me_about_comments'),
              'Chcę otrzymywać newsletter o budżecie obywatelskim w Warszawie.',
              'Chcę otrzymywać powiadomienia na mój adres e-mail o aktualizacji stanu realizacji projektów, które obserwuję.',
              'Chcę otrzymywać powiadomienia na mój adres e-mail o zmianach wprowadzanych w moich projektach',
              'Czy jest autorem projektu (TAK/NIE)',
              'Liczba projektów dla których jest autorem projektu',
              'Numery projektów, dla których jest autorem projektu',
              'Czy są kopie robocze projektów (TAK/NIE)',
              'Liczba kopii roboczych projektów',
              'Czy jest współautorem (TAK/NIE)',
              'Liczba projektów dla których jest współautorem',
              'Numery projektów, dla których jest współautorem'
            ]
          end

          def add_project_row(p)
            row = [
              p.voting_number,
              p.esog_number,
              p.is_paper ? 'papierowy' : 'elektroniczny',
              begin
                p.published_at.strftime('%d-%m-%Y %H:%M:%S')
              rescue StandardError
                nil
              end,
              p.title,
              begin
                p.authors.first.id
              rescue StandardError
                'błąd?'
              end,
              p.coauthors.any? ? 'TAK' : 'NIE', # 'informacja o współautorach (TAK/NIE)',
              p.coauthors.map(&:id).compact.join(', '), # 'numery użytkownika współautorów',
              p.coauthors.count, # 'liczba współautorów',
              p.short_description,
              (p.scope.scope_type.name['pl'] rescue nil), # 'poziom',
              (p.scope.name["pl"] rescue nil), # dzielnica
              p.region&.name,
              p.localization_info,
              p.localization_additional_info
            ]
            category_ids.each do |item|
              row << (p.category_ids.include?(item) ? 'TAK' : 'NIE')
            end
            recipient_ids.each do |item|
              row << (p.recipient_ids.include?(item) ? 'TAK' : 'NIE')
            end
            row + [
              ActionView::Base.full_sanitizer.sanitize(p.availability_description),
              ActionView::Base.full_sanitizer.sanitize(p.body),
              p.justification_info,
              p.budget_description,
              p.contractors_and_costs,
              p.budget_value,
              p.producer_list, # 'jednostka odpowiadająca za realizację',

              p.future_maintenance.nil? ? nil : (p.future_maintenance ? 'TAK' : 'NIE' ),
              p.future_maintenance_description,
              (p.future_maintenance.nil? ? nil : p.future_maintenance_value),
              I18n.t(p.state, scope: 'decidim.admin.filters.projects.state_eq.values'),
              assigned_to(p), # 'dane przypisanych użytkowników (nazwa oraz kontakt)',
              p.current_department&.name.presence || '', # 'Aktualna komórka',

              p.current_sub_coordinator&.ad_full_name.presence || '', # 'Przypisany podkoordynator',
              p.current_sub_coordinator&.email || '', # 'Adres e-mail podkoordynatora',
              p.current_sub_coordinator ? p.current_sub_coordinator.public_name(true) : '', # Nazwa wyświetlana podkoordynatora

              p.evaluator&.ad_full_name.presence || '', # 'Przypisany weryfikator',
              p.evaluator&.email.presence || '', # 'Adres e-mail weryfikatora'
              p.evaluator ? p.evaluator.public_name(true) : '', # Nazwa wyświetlana weryfikatora

              p.formal_result.nil? ? '' : (p.formal_result ? 'Pozytywny' : 'Negatywny'), # wynik oceny formalnej
              p.formal_result.nil? ? '' : (p.formal_result ? '---' : (p.formal_evaluation&.negative_reasons_for_xls rescue 'Negatywny')), # Powód negatywnej oceny formalnej
              p.meritorical_result.nil? ? '' : (p.meritorical_result ? 'Pozytywny' : 'Negatywny'), # wynik oceny merytorycznej
              p.actual_reevaluation_result, # Wynik ponownej oceny
              (p.meritorical_evaluation&.details['project_implementation_effects'] rescue ''), # skutki realizacji
              (p.meritorical_evaluation&.details['result_description'] rescue ''), # przyczyna oceny negatywnej
              p.appeal&.time_of_submit,
              p.appeal&.body,

              # Decidim::Attachment.first.title['pl'].include?('dostepna')
              (p.formal_evaluation.attachments.scans.any? ? 'TAK' : 'NIE' rescue 'NIE'),
              (p.formal_evaluation.attachments.available.any? ? 'TAK' : 'NIE' rescue 'NIE'),
              (p.meritorical_evaluation.attachments.scans.any? ? 'TAK' : 'NIE' rescue 'NIE'),
              (p.meritorical_evaluation.attachments.available.any? ? 'TAK' : 'NIE' rescue 'NIE'),
              # (p.reevaluation.attachments.where(eval_file_type: "scan").any? ? 'TAK' : 'NIE' rescue 'NIE'), # Karta ponownej oceny – skan (TAK/NIE)
              (p.reevaluation.attachments.any? ? 'TAK' : 'NIE' rescue 'NIE'), # Karta ponownej oceny – skan (TAK/NIE)
              (p.reevaluation.attachments.where(eval_file_type: "available").any? ? 'TAK' : 'NIE' rescue 'NIE'), # Karta ponownej oceny – dostępna (TAK/NIE)
              p.remarks,                                              # Uwagi osoby wprowadzającej formularz papierowy
              (p.formal_evaluation.notes rescue ''),                  # Uwagi oceny formalnej
              (p.meritorical_evaluation.changes_info_notes rescue ''),# Uwagi oceny merytorycznej
              (p.meritorical_evaluation&.details['notes'] rescue ''), # Dodatkowe informacje
              (p.meritorical_evaluation.details["unit_name"] rescue nil),     # Podmiot dokonujący oceny merytorycznej
              (p.meritorical_evaluation.details["verifier_name"] rescue nil), # Imię i nazwisko pracownika oceniającego
              (p.reevaluation.details["reevaluator_user_name"] rescue nil),   # Imię i nazwisko osoby dokonującej ponowną ocenę
              p.consents.any? ? 'TAK' : 'NIE',
              p.votes_count,
              Decidim::ResourceLocatorPresenter.new(p).url,
              (p.notification_about_evaluation_results_send_at.strftime("%d-%m-%Y %H:%M:%S") rescue nil),
              p.notification_about_evaluation_results_send_by&.ad_full_name.presence || ''
            ]
          end

          def add_full_project_row(p)
            c = p.creator_author
            if p.coauthors.any?
              first_coauthor = p.coauthors.first.present? ? p.coauthors.first : Decidim::User.new
              second_coauthor = p.coauthors.second.present? ? p.coauthors.second : Decidim::User.new
            else
              first_coauthor = Decidim::User.new
              second_coauthor = Decidim::User.new
            end

            user_fields(c) + user_fields(first_coauthor) + user_fields(second_coauthor) + add_project_row(p)
          end

          def user_fields(user)
            [
              user.first_name,
              user.last_name,
              user.gender ? (user.gender == 'male' ? 'Mieszkaniec' : 'Mieszkanka') : nil,
              user.email,
              user.phone_number,
              user.street,
              user.street_number,
              user.flat_number,
              user.city,
              user.zip_code
            ]
          end

          def assigned_to(project)
            arr = []
            project.department_assignments.each do |da|
              arr << da.department&.name
            end
            project.user_assignments.each do |ua|
              arr << ua.user.public_name(true)
            end
            # if project.current_department
            #   arr << "Komórka: #{project.current_department&.name }"
            # end
            # if project.current_sub_coordinator
            #   arr << "Podkoordynator: #{project.current_sub_coordinator.ad_full_name}, #{project.current_sub_coordinator.email}"
            # end
            # if project.evaluator
            #   arr << "Weryfikator: #{project.evaluator.ad_full_name}, #{project.evaluator.email}"
            # end

            arr.uniq.map{ |e| e if e.present? }.compact.join(", ")
          end
        end
      end
    end
  end
end
