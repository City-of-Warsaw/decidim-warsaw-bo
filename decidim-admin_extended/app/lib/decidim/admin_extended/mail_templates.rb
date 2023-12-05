# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Module with mail templates
    module MailTemplates
      # public method
      # system_name: Hash with attributes
      def templates
        {
          # users
          activation_email_template: {
            name: 'Aktywacja konta w systemie dla użytkownika',
            subject: 'Budżet obywatelski - Aktywacja konta',
            body: "
            <p>Dziękujemy za założenie konta na stronie budżetu obywatelskiego w&nbsp;Warszawie.</p>
            <p>W celu potwierdzenia rejestracji, prosimy o kliknięcie w poniższy link:</p>
            <a href='%{activation_link}' class='button'>Aktywuj konto</a>
          "
          },
          password_change_email_template: {
            name: 'Zmiana hasła w systemie dla użytkownika',
            subject: 'Budżet obywatelski - Zmiana hasła',
            body: "
            <p>Otrzymaliśmy prośbę o zmianę hasła na stronie budżetu obywatelskiego w&nbsp;Warszawie.</p>
            <p>Jeżeli&nbsp;chcesz zmienić hasło, kliknij w poniższy link</p>
            <a href='%{password_reset_link}' class='button'>Link do zmiany hasła</a>
            <p>W przeciwnym wypadku prosimy zignorować ten e-mail.</p>
            "
          },
          new_private_message: {
            name: 'Powiadomienie o wiadomości prywatnej dla użytkowników',
            subject: 'Budżet obywatelski - Prywatna wiadomość',
            body: "
            <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
            <p>Jeden z użytkowników budżetu obywatelskiego w&nbsp;Warszawie chciał się z Tobą skontaktować.</p>
            <p>Poniżej znajduje się jego adres e-mail, na który możesz odpisać, oraz treść wiadomości:</p>
            <p>%{sender_email}</p>
            <p>%{private_message_body}</p>
            <p>Jeśli treść jest nieodpowiednia, zgłoś ją nam.</p>
            <p>Z poważaniem
            <br>
            Urząd m.st. Warszawy</p>
            "
          },

          # project
          remind_about_draft_project_template: {
            name: 'Przypomnienie o kopii roboczej',
            subject: 'Budżet obywatelski - dokończ zgłaszanie projektu!',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
<p>jeszcze nie wszystkie Twoje pomysły zostały zgłoszone do budżetu obywatelskiego. Na Twoim koncie wciąż znajdują się kopie robocze projektów.
<br>Jeśli chcesz je zgłosić w tej edycji, masz ostatnią szansę! Możesz to zrobić jeszcze tylko dzisiaj (do godz. 23:59).
<br>Wejdź na stronę <a href='https://bo.um.warszawa.pl'>bo.um.warszawa.pl</a>, dokończ opisywanie swojego pomysłu i zgłoś go!
</p>
<p>
  Jeśli potrzebujesz pomocy lub uważasz, że ten e-mail został wysłany do Ciebie przez pomyłkę,
  napisz na adres <a href='mailto:bo@um.warszawa.pl'>bo@um.warszawa.pl</a>.
</p>
<p>Z poważaniem
<br>Urząd m.st. Warszawy</p>
          "
          },
          project_published_email_template: {
            name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Zgłoszony”',
            subject: 'Budżet obywatelski - Dziękujemy za złożenie projektu!',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
          <p>potwierdzamy złożenie projektu <a href='%{project_link}'>%{project_title}</a> do budżetu obywatelskiego w Warszawie na rok 2023.</p>
          <p>Pamiętaj, że zgłoszony pomysł możesz jeszcze edytować do 25 stycznia 2022 (do godz. 23:59).</p>
          <p>Wszystkie złożone projekty są opublikowane na stronie internetowej bo.um.warszawa.pl w zakładce Przeglądaj projekty.</p>

          <p>Z poważaniem
          <br>
          Urząd m.st. Warszawy</p>
          "
          },
          author_invitation_email_template: {
            name: 'Treść wiadomości e-mail dla autora projektu w wersji papierowej z informacją o możliwości założenia konta',
            subject: 'Budżet obywatelski - Twój projekt został wprowadzony do systemu',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
          <p>ponieważ zgłosiłaś(-eś) projekt na formularzu papierowym, pracownicy Urzędu wprowadzili go do systemu internetowego.
          Przy użyciu adres e-mail podanego w formularzu możesz zalogować się na swoje konto, żeby odpowiadać na komentarze innych użytkowników. Kliknij w <a href='%{password_reset_link}'>link do zmiany hasła</a>, żeby ustawić hasło.</p>
          <p>Jeśli potrzebujesz pomocy lub uważasz, że ten e-mail został wysłany do Ciebie przez pomyłkę, napisz na adres: bo@um.warszawa.pl.</p>
          <p>
          Z poważaniem
          Urząd m.st. Warszawy
          </p>
          "
          },
          coauthor_invitation_email_template: {
            name: 'Treść wiadomości e-mail dla współautora z informacją o możliwości założenia konta',
            subject: 'Budżet obywatelski - Zostałaś(-eś) dodana(-y) jako współautor projektu ',
            body: "
<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
<p>zostałaś(-eś) dodana(-y) jako współautor projektu <a href='%{project_link}'>%{project_title}</a>
zgłoszonego w ramach budżetu obywatelskiego w Warszawie.</p>
<p>Aby potwierdzić status współautora, musisz założyć konto w systemie internetowym.</p>
<p>W celu założenia konta, prosimy przejść na stronę: <a href='%{registration_link}'>link do rejestracji</a>.
Pamiętaj, aby przy zakładaniu konta użyć adresu e-mail, na który otrzymałeś tę wiadomość.
Inaczej nie będziemy w stanie zidentyfikować Ciebie jako współautora projektu.</p>
<p>Jeśli potrzebujesz pomocy lub uważasz, że ten e-mail został wysłany do Ciebie przez pomyłkę, napisz na adres: bo@um.warszawa.pl.</p>
<p>
Z poważaniem
Urząd m.st. Warszawy
</p>
"
          },
          coauthorship_confirmation_email_template: {
            name: 'Treść wiadomości e-mail dla współautora z informacją o potwierdzeniu statusu współautora',
            subject: 'Budżet obywatelski - Zostałaś(-eś) dodana(-y) jako współautor projektu',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
          <p>zostałaś(-eś) dodana(-y) jako współautor projektu <a href='%{project_link}'>%{project_title}</a>
          zgłoszonego w ramach budżetu obywatelskiego w Warszawie.</p>
          <p>Aby potwierdzić status współautora kliknij w link: <a href='%{coauthorship_acceptance_link}'>potwierdzenie współautorstwa</a>.</p>
          <p>Jeśli potrzebujesz pomocy lub uważasz, że ten e-mail został wysłany do Ciebie przez pomyłkę, napisz na adres: bo@um.warszawa.pl.</p>
          <p>
          Z poważaniem
          Urząd m.st. Warszawy
          </p>
          "
          },
          applicant_information_after_project_edit_email_template: {
            name: 'Treść wiadomości e-mail dla wnioskodawców wysyłanej po edycji projektu przez autora',
            subject: 'Budżet obywatelski - Potwierdzenie edycji projektu',
            body: "
 <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
<p>potwierdzamy wprowadzenie zmian do treści projektu <a href='%{project_link}'>%{project_title}</a> zgłoszonego do budżetu obywatelskiego w Warszawie na rok 2023.</p>
<p>Zgłoszony pomysł może być ponownie modyfikować do 25 stycznia 2022 (do godz. 23:59).</p>
<p>Jeśli potrzebujesz pomocy lub uważasz, że ten e-mail został wysłany do Ciebie przez pomyłkę, napisz do nas na adres: bo@um.warszawa.pl.</p>
<p>
Z poważaniem
Urząd m.st. Warszawy</p>
"
          },
          admin_edition_project_email_template: {
            name: 'Treść wiadomości e-mail wysyłanej do projektodawcy po aktualizacji projektu przez pracowników urzędu',
            subject: 'Budżet obywatelski - Twój projekt został zmieniony',
            body: "
            <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
            <p>w Twoim projekcie <a href='%{project_link}'>%{project_title}</a> zgłoszonym w ramach budżetu obywatelskiego w Warszawie
            pracownicy Urzędu wprowadzili zmiany.</p>
            <p>Zakres zmian możesz sprawdzić na karcie projektu w sekcji 'Modyfikacje'.</p>
            <p>Jeśli masz pytania lub wątpliwości, skontaktuj się z pracownikiem urzędu oceniającym projekt lub właściwym koordynatorem ds. budżetu obywatelskiego.</p>
            <p>
            Z poważaniem
            Urząd m.st. Warszawy</p>
            "
          },
          withdrawn_project_email_template: {
            name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Wycofany przez autora”',
            subject: 'Budżet obywatelski – Projekt został wycofany',
            body: "
            <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
            <p>
            potwierdzamy wycofanie projektu <a href='%{project_link}'>%{project_title}</a>. Projekt nadal będzie widoczny na stronie, ale nie będzie już dalej procedowany.
            </p>
            <p>
            Jeśli masz pytania, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego lub napisz do nas na adres bo@um.warszawa.pl.
            </p>
            <p>
            Z poważaniem
            Urząd m.st. Warszawy
            </p>
            "
          },
          withdrawn_project_email_coauthor_template: {
            name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Wycofany przez autora” - powiadomienie dla współautorów',
            subject: 'Budżet obywatelski – Projekt został wycofany',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
          <p>
          Autor wycofał projekt <a href='%{project_link}'>%{project_title}</a>. Projekt nadal będzie widoczny na stronie, ale nie będzie już dalej procedowany.
          </p>
          <p>
          Jeśli masz pytania, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego lub napisz do nas na adres bo@um.warszawa.pl.
          </p>
          <p>
          Z poważaniem
          Urząd m.st. Warszawy
          </p>
          "
          },
          withdrawn_project_email_inner_users_template: {
            name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Wycofany przez autora” - powiadomienie dla użytkowników wewnętrznych',
            subject: 'Budżet obywatelski – Projekt został wycofany',
            body: "<p>Projekt został wycofany przez autora <a href='%{project_link}'>%{project_title}</a>.</p> "
          },
          negative_evaluation_email_template: {
            name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Oceniony negatywnie”',
            subject: 'Budżet obywatelski – Twój projekt został oceniony negatywnie',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
<p>
Twój projekt <a href='%{project_link}'>%{project_title}</a> został oceniony negatywnie. Niestety, nie zostanie poddany pod głosowanie mieszkańców.
</p><p>
Uzasadnienie:
</p><p>
%{reason_body}
</p><p>
Jeśli masz pytania dotyczące przebiegu oceny, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego.
</p><p>
Autorom projektów przysługuje prawo odwołania się od wyniku oceny. Odwołanie można złożyć elektronicznie (logując się na swoje konto na stronie bo.um.warszawa.pl) lub papierowo od 4 do 11 maja 2022 r.
</p><p>
Informacja o wyniku ponownej oceny zostanie przekazana projektodawcom najpóźniej 31 maja 2022 roku. Wynik ponownej oceny będzie ostateczny.
</p><p>
Z poważaniem
Urząd m.st. Warszawy
</p>
"
          },
          positive_evaluation_email_template: {
            name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Dopuszczony do głosowania”',
            subject: 'Budżet obywatelski - Twój projekt został dopuszczony do głosowania',
            body: "
<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,
</p><p>
Twój projekt <a href='%{project_link}'>%{project_title}</a> został oceniony pozytywnie i będzie poddany pod głosowanie mieszkańców.
</p><p>
Warto wypromować swój projekt i zachęcić jak najwięcej osób do głosowania.
</p><p>
Kolejność projektów na listach do głosowania zostanie ustalona poprzez losowanie i opublikowana najpóźniej do 1 czerwca. Głosowanie na projekty będzie trwało od 15 do 30 czerwca br. Można głosować przez Internet na stronie bo.um.warszawa.pl albo papierowo – wypełnioną kartę do głosowania należy przynieść do właściwego urzędu dzielnicy.
</p><p>
Jeśli masz pytania dotyczące przebiegu oceny lub głosowania, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego.
</p><p>
Z poważaniem
Urząd m.st. Warszawy</p>
"
          },
          # selectedt_project_email_template: {
          #   # Not implemented
          #   name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Wybrany w głosowaniu”',
          #   subject: '',
          #   body: ""
          # },
          # not_selected_project_email_template: {
          #   # not implemented
          #   name: 'Treść wiadomości e-mail dla projektu przechodzącego w stan “Niewybrany w głosowaniu”',
          #   subject: '',
          #   body: ""
          # },
          # Appeal & Reevaluation
          appeal_submited_admin_info_email_template: {
            name: 'Informacja o odwołaniu wysyłana do koordynatorów/weryfikatorów/podkoordynatorów',
            subject: 'Budżet obywatelski – Informacja o złożonym odwołaniu',
            body: "
                <p>Wpłynęło odwołanie od negatywnej oceny projektu <a href='%{project_link}'>%{project_title}</a>. Z  treścią odwołania możesz się zapoznać po zalogowaniu do panelu administratora.
                </p><p>
                Bezpośredni link to treści odwołania: <a href='%{appeal_link}'>link do odwołania</a>.
                </p>
                "
          },
          appeal_submitted_author_info_email_template: {
            name: 'Informacja o odwołaniu wysyłana do autora odwołania',
            subject: 'Budżet obywatelski – potwierdzenie złożenia odwołania',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,
</p><p>
potwierdzamy złożenia odwołania od oceny projektu  <a href='%{project_link}'>%{project_title}</a>. Informacja o wyniku ponownej oceny zostanie przekazana  (wraz z uzasadnieniem) najpóźniej 31 maja 2022 roku. Wynik ponownej oceny będzie ostateczny.
</p><p>
Treść odwołania: %{appeal_body}
</p><p>
Jeśli masz pytania dotyczące przebiegu ponownej oceny, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego.
</p><p>
Z poważaniem
Urząd m.st. Warszawy
</p>"
          },
          finish_appeal_draft: {
            name: 'Użytkownik wewnętrzny zgłosił wprowadzone odwołanie papierowe',
            subject: 'Zgłoszono papierowe odwołanie',
            body: "
                <p>Wpłynęło odwołanie od negatywnej oceny projektu <a href='%{project_link}'>%{project_title}</a>.<br>
                Z treścią odwołania możesz się zapoznać po zalogowaniu do panelu administratora.
                </p><p>
                Bezpośredni link to treści odwołania: <a href='%{appeal_link}'>link do odwołania</a>.
                </p>"
          },
          positive_reevaluation_email_template: {
            name: 'Pozytywny wynik ponownej oceny',
            subject: 'Budżet obywatelski - Twój projekt został dopuszczony do głosowania',
            body: "
<p>
Szanowna Mieszkanko, Szanowny Mieszkańcu,
</p><p>
wynik oceny Twojego projektu  <a href='%{project_link}'>%{project_title}</a> został zmieniony na pozytywny. Projekt będzie poddany pod głosowanie mieszkańców.
</p><p>
Warto wypromować swój projekt i zachęcić jak najwięcej osób do głosowania.
</p><p>
Kolejność projektów na listach do głosowania zostanie ustalona poprzez losowanie i opublikowana najpóźniej do 1 czerwca. Głosowanie na projekty będzie trwało od 15 do 30 czerwca br. Można głosować przez Internet na stronie bo.um.warszawa.pl albo papierowo – wypełnioną kartę do głosowania należy przynieść do właściwego urzędu dzielnicy.
</p><p>
Jeśli masz pytania dotyczące przebiegu ponownej oceny lub głosowania, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego.
</p><p>
Z poważaniem
Urząd m.st. Warszawy
</p>
"
          },
          negative_reevaluation_email_template: {
            name: 'Negatywny wynik ponownej oceny',
            subject: 'Budżet obywatelski - Twój projekt został oceniony negatywnie ',
            body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
          <p>
          Twój projekt  <a href='%{project_link}'>%{project_title}</a> został ponownie sprawdzony przez pracowników Urzędu. Niestety, wynik ponownej oceny nie zmienił się i projekt nie zostanie poddany pod głosowanie mieszkańców. Uzasadnienie znajdziesz w karcie ponownej oceny dostępnej pod Twoim projektem.
          </p><p>
          Jeśli masz pytania dotyczące przebiegu ponownej oceny, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego.
          </p><p>
          Z poważaniem
          Urząd m.st. Warszawy
          </p>"
          },

          # Assignement to verification
          project_assigned_for_verification_email_template: {
            name: 'Zmiana weryfikatora',
            subject: 'Budżet obywatelski - Informacja o przypisaniu projektu do oceny',
            body: "
            <p>
            %{current_role} ds. budżetu obywatelskiego w %{current_type} %{current_department}
            przekazał Ci projekt <a href='%{project_link}'>%{project_title}</a> do oceny.
            Jeżeli masz pytania dotyczące zasad przebiegu oceny, skontaktuj się z właściwym
            koordynatorem ds. budżetu obywatelskiego.
            </p>
            "
          },
          project_assigned_for_formal_verification: {
            name: 'Przydzielenie weryfikatora do oceny formalnej',
            subject: 'Budżet obywatelski - Informacja o przypisaniu projektu do oceny',
            body: "
            <p>
            %{current_role} ds. budżetu obywatelskiego w %{current_type} %{current_department}
            przekazał Ci projekt <a href='%{project_link}'>%{project_title}</a> do oceny formalnej.
            Jeżeli masz pytania dotyczące zasad przebiegu oceny, skontaktuj się z właściwym
            koordynatorem ds. budżetu obywatelskiego.
            </p>
            "
          },
          project_assigned_for_meritorical_verification: {
            name: 'Przydzielenie weryfikatora do oceny merytorycznej',
            subject: 'Budżet obywatelski - Informacja o przypisaniu projektu do oceny',
            body: "
            <p>
            %{current_role} ds. budżetu obywatelskiego w %{current_type} %{current_department}
            przekazał Ci projekt <a href='%{project_link}'>%{project_title}</a> do oceny merytorycznej.
            Jeżeli masz pytania dotyczące zasad przebiegu oceny, skontaktuj się z właściwym
            koordynatorem ds. budżetu obywatelskiego.
            </p>
            "
          },
          project_assigned_for_reevaluation_verification: {
            name: 'Przydzielenie weryfikatora do ponownej oceny',
            subject: 'Budżet obywatelski - Informacja o przypisaniu projektu do oceny',
            body: "
            <p>
            %{current_role} ds. budżetu obywatelskiego w %{current_type} %{current_department}
            przekazał Ci projekt <a href='%{project_link}'>%{project_title}</a> do ponownej oceny.
            Jeżeli masz pytania dotyczące zasad przebiegu oceny, skontaktuj się z właściwym
            koordynatorem ds. budżetu obywatelskiego.
            </p>
            "
          },
          project_assigned_for_management_email_template: {
            name: 'Przydzielenie podkoordynatora',
            subject: 'Budżet obywatelski - Informacja o przypisaniu projektu',
            body: "
            <p>
            Koordynator ds. budżetu obywatelskiego w biurze / jednostce %{current_department}
            przekazał Ci projekt <a href='%{project_link}'>%{project_title}</a>
            do %{evaluation_name}. Jeżeli masz pytania dotyczące zasad przebiegu oceny, skontaktuj się z
            koordynatorem ds. budżetu obywatelskiego.
            </p>"
          },
          project_assigned_to_department_email_template: {
            name: 'Przypisanie projektu do jednostki',
            subject: 'Budżet obywatelski - Informacja o przekazaniu projektu do Twojej komórki',
            body: "
          <p>Koordynator ds. budżetu obywatelskiego przekazał projekt <a href='%{project_link}'>%{project_title}</a>
          do Twojej komórki. Zaloguj się do systemu, aby przydzielić projekt do podkoordynatora lub weryfikatora
          odpowiedzialnego za ocenę merytoryczną.</p>
          "
          },
          meritorical_finished: {
            name: 'Zaakceptowanie oceny',
            subject: 'Budżet obywatelski - weryfikator zakończył ocenę merytoryczną projektu',
            body: "
          <p>Witaj %{user_name},</p>
          <p>
          Weryfikator %{verifier_name} zakończył ocenę merytoryczną projektu <a href='%{project_link}'>%{project_title}</a>
          <br>Pamiętaj o zatwierdzeniu ostatecznej oceny projektu.
          </p>
          "
          },
          finish_appeal_verification: {
            name: 'Przekazanie ponownej oceny do koordynatora',
            subject: 'Budżet obywatelski - weryfikator zakończył ponowną ocenę projektu',
            body: "
          <p>Witaj %{user_name},</p>
          <p>
          Weryfikator %{verifier_name} zakończył ponowną ocenę projektu <a href='%{project_link}'>%{project_title}</a>
          <br>Pamiętaj o zatwierdzeniu oceny.
          </p>
          "
          },
          invitation_for_voting: {
            name: 'Treść wiadomości email z zaproszeniem do głosowania',
            subject: "Rozpocznij głosowanie w budżecie obywatelskim",
            body: '<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
            <p>Rozpocząłeś/aś głosowanie w warszawskim budżecie obywatelskim na %{edition_year}  rok.
               Kliknij w poniższy link, aby kontynuować głosowanie:</p>
            %{voting_button}
            <p>
              Zagłosować możesz do %{voting_end_date}.
            </p><p>
          Z poważaniem<br>
Urząd m.st. Warszawy<br>
Budżet obywatelski w Warszawie
          </p>'
          },
          resend_invitation_for_voting: {
            name: 'Treść wiadomości email z ponownym zaproszeniem do głosowania',
            subject: "Rozpocznij głosowanie w budżecie obywatelskim",
            body: '<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
            <p>Dokończ głosowanie w warszawskim budżecie obywatelskim na %{edition_year}  rok.
               Kliknij w poniższy link, aby kontynuować głosowanie:</p>
             %{voting_button}
              Zagłosować możesz do %{voting_end_date}.
            </p><p>
          Z poważaniem<br>
          Urząd m.st. Warszawy<br>
          Budżet obywatelski w Warszawie
          </p>'
          },
          thank_you_for_voting: {
            name: 'Treść wiadomości email z podziękowaniem o głosowaniu',
            subject: 'Dziękujemy za Twój głos w budżecie obywatelskim',
            body: "<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
            <p>dziękujemy za zagłosowanie w warszawskim budżecie obywatelskim na %{edition_year} rok. Zagłosowałeś/aś na następujące propozycje:</p>
            %{districts_projects}
            %{global_projects}
            <p>
            Wyniki ogłosimy %{voting_publication_time} roku.
           <br>
           Pomysły, które zwyciężą w głosowaniu, zostaną zrealizowane przez Miasto.
           </p><p>
          Z poważaniem<br>
          Urząd m.st. Warszawy<br>
          Budżet obywatelski w Warszawie
          </p>"
          },
          # projects_assignet_to_bureau_email_template: {
          #   # NO WAY FOR IMPLEMENTATION
          #   name: 'Treść wiadomości e-mail z informacją o przypisaniu projektu do biura',
          #   subject: '',
          #   body: ""
          # },
          # Statuses
          # project_status_changed_author_info_email_template: {
          #   name: 'Treść wiadomości e-mail dla poinformowania autora o zmianie statusu projektu',
          #   subject: '',
          #   body: ""
          # },
          implementation_status_changed_author_info_email_template: {
            name: 'Poinformowania autora o zmianie stanu realizacji',
            subject: 'Budżet obywatelski - Informacja o realizacji Twojego projektu',
            body: "
           <p>
            Szanowna Mieszkanko, Szanowny Mieszkańcu,
            </p><p>
            na stronie bo.um.warszawa.pl pojawiła się aktualizacji dotycząca realizacji projektu  <a href='%{project_link}'>%{project_title}</a>.
            </p><p>
            Status: %{implementation_status}
            </p><p>
            Informacja o stanie realizacji: %{implementation_body}
            </p><p>
            Jeśli masz pytania dotyczące realizacji projektu, skontaktuj się z właściwym koordynatorem ds. budżetu obywatelskiego.
            </p><p>
            Z poważaniem
            Urząd m.st. Warszawy
            </p>"
          },
          new_conversation: {
            name: 'Nowa wiadomość prywatna z użytkownikiem',
            subject: 'Budżet obywatelski - Wiadomość prywatna od innego użytkownika',
            body: "
           <p>
            Szanowna Mieszkanko, Szanowny Mieszkańcu,
            </p><p>
            Na stronie bo.um.warszawa.pl pojawiła się nowa wiadomość prywatna od innego użytkownika.
            </p><p>
            Aby przeczytać wiadomość wejdź: <a href='https://bo.um.warszawa.pl/conversations'>konwersacje</a>.
            </p><p>
            Z poważaniem
            Urząd m.st. Warszawy
            </p>"
          },

          # Comments
          new_comment_project_author_info_email_template: {
            name: 'Poinformowanie autora projektu o nowym komentarzu',
            subject: 'Budżet obywatelski - Pojawił się nowy komentarz do Twojego projektu',
            body: "
            <p>
              Szanowna Mieszkanko, Szanowny Mieszkańcu,
              </p><p>
              Pojawił się nowy komentarz na karcie Twojego projektu  <a href='%{project_link}'>%{project_title}</a>.
              </p><p>
              Treść komentarza: %{comment_body}
              </p><p>
              Aby odpowiedzieć, zaloguj się na swoje konto w systemie.
              </p><p>
              Z poważaniem
              Urząd m.st. Warszawy
              </p>"
          },
          new_comment_interlocutor_info_email_template: {
            name: 'Poinformowania uczestnika dyskusji o nowym komentarzu',
            subject: 'Budżet obywatelski - Pojawił się nowy komentarz w dyskusji, w której uczestniczysz',
            body: "
          <p>
          Szanowna Mieszkanko, Szanowny Mieszkańcu,
          </p><p>
          Pojawił się nowy komentarz w dyskusji, w której uczestniczysz: <a href='%{comment_link}'>%{project_title}</a>.
          </p><p>
          Treść komentarza: %{comment_body}
          </p><p>
          Aby odpowiedzieć, zaloguj się na swoje konto w systemie.
          </p><p>
          Z poważaniem
          Urząd m.st. Warszawy
          </p>"
          },
          # comment_updated_project_author_info_email_template: {
          #   # Not implemented
          #   name: 'Treść wiadomości e-mail dla poinformowania autora projektu o edycji komentarza',
          #   system_name: 'comment_updated_project_author_info_email_template',
          #   subject: '',
          #   body: ""
          # },
          # comment_edited_interlocutor_info_email_template: {
          #   # not implemented
          #   name: 'Treść wiadomości e-mail dla poinformowania uczestnika dyskusji o edycji komentarza',
          #   system_name: 'comment_edited_interlocutor_info_email_template',
          #   subject: '',
          #   body: ""
          # },

          # NOT IMPLEMENTED
          comment_deleted_comment_author_info_email_template: {
            name: 'Poinformowania użytkownika o usunięciu jego komentarza przez administracje',
            subject: 'Budżet obywatelski - Twój komentarz został usunięty',
            body: "<p>
            Szanowna Mieszkanko, Szanowny Mieszkańcu,
            </p><p>
            Twój komentarz zamieszczony pod projektem  <a href='%{project_link}'>%{project_title}</a> został usunięty
            przez Administratora z powodu naruszenia regulaminu korzystania z systemu:  <a href='%{terms_and_conditions_link}'>link do regulaminu</a>.
            </p><p>
            Treść komentarza: %{comment_body}
            </p><p>
            Z poważaniem
            Urząd m.st. Warszawy
            </p>"
          },
          final_acceptance_admin_info: {
            name: 'Poinformowanie administratora o przydzieleniu projektu do finalnej akceptacji',
            subject: 'Przekazano projekt do akceptacji',
            body: "
          <p>Witaj %{user_name},</p>
          <p>
          Ponowna ocena projektu została przekazana do ostatecznej weryfikacji</p>
          <p> <a href='%{project_link}'>%{project_title}</a></p>
          "
          },
          return_reevaluation_from_admin_to_coordinator: {
            name: 'Poinformowanie koordynatorów o zwróceniu projektu przez CKS do ponownej weryfikacji',
            subject: 'Zwrócono projekt do akceptacji/weryfikacji',
            body: "
          <p>Witaj %{user_name},</p>
          <p>
          Projekt <a href='%{project_link}'>%{project_title}</a> został zwrócony przez %{verifier_name} do ponownej weryfikacji
          </p>
          "
          },
          result_voting_loosing_project: {
            name: "Wyniki głosowania - Projekt przegrany",
            subject: "Budżet obywatelski - wyniki głosowania",
            body: "<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
                  <p>ogłosiliśmy wyniki głosowania w budżecie obywatelskim.</p>
                  <p>Niestety Twój projekt <a href='%{project_public_link}'> %{project_title}</a>  nie uzyskał wystarczającego poparcia mieszkańców w głosowaniu i nie zostanie zrealizowany.</p>
                  <p>
                    Szczegółowe wyniki znajdziesz na stronie:
                     <a href='http://bo.um.warszawa.pl/'>http://bo.um.warszawa.pl/</a>.
                  </p><p>
                  Z poważaniem
                  Urząd m.st. Warszawy
                  </p>"
          },
          result_voting_winning_project: {
            name: "Wyniki głosowania - Projekt wygrany",
            subject: "Budżet obywatelski - wyniki głosowania",
            body: "<p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
                  <p>ogłosiliśmy wyniki głosowania w budżecie obywatelskim.</p>
                  <p><strong>Gratulujemy!</strong>
                    <br>
                    Twój projekt <a href='%{project_public_link}'> %{project_title}</a> został wybrany przez mieszkańców w głosowaniu i zostanie zrealizowany przez Miasto w %{realization_year} roku.
                  </p>
                  <p>
                    Szczegółowe wyniki znajdziesz na stronie:
                    <a href='http://bo.um.warszawa.pl/'>http://bo.um.warszawa.pl/</a>.
                  </p><p>
                  Z poważaniem
                  Urząd m.st. Warszawy
                  </p>"
          },
          accept_coordinator_reevaluation: {
            name: 'Poinformowanie administratorów o akceptacji projektu przez koordynatora',
            subject: 'Zaakceptowano projekt',
            body: "
          <p>Witaj %{user_name},</p>
          <p>
           Ponowna ocena projektu została zaakceptowana przez koordynatora</p>
          <p> <a href='%{project_link}'>%{project_title}</a></p>
          "
          }

        }
      end
    end
  end
end
