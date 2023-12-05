# frozen_string_literal: true


module MeritoricalEvaluationFieldsDefinition
  MERITORICAL_FIELDS = [
    {
      name: 'q1',
      label: 'Projekt nie narusza przepisów prawa powszechnie obowiązującego, w tym aktów prawa miejscowego',
      type: 'radio', not_applicable: false,
      tooltip: 'Sprawdź, czy realizacja projektu nie naruszałaby przepisów, które są związane z działaniami opisanymi w projekcie. Pamiętaj o sprawdzeniu wszystkich dokumentów, które mogą być istotne przy ocenie projektu np.: przepisy prawa miejscowego (m.in. miejscowe plany zagospodarowania przestrzennego, uchwały Rady m.st. Warszawy) i dokumenty wyższego rzędu (np. ustawa o zapewnianiu dostępności osobom ze szczególnymi potrzebami, ustawa - Prawo budowalne, ustawa - Prawo o ruchu drogowym, ustawa o finansach publicznych itd.)'
    },
    {
      name: 'q2',
      label: 'Projekt mieści się w zakresie zadań własnych m.st. Warszawy',
      type: 'radio', not_applicable: false,
      tooltip: 'Sprawdź, czy opisane w projekcie działania mieszczą się w kompetencjach m.st. Warszawy.  Jeśli nie masz pewności, przejrzyj takie dokumenty jak: Statut m.st. Warszawy, Ustawa o ustroju m.st. Warszawy, Uchwała kompetencyjna, Ustawa o samorządzie gminnym, Ustawa o samorządzie powiatowym.<br /><br />Zdecydowana większość projektów, które będziesz oceniać są związane z tematami, którymi zajmujesz się na co dzień, dlatego od razu będziesz wiedział, czy mieści się z zadaniach m.st. Warszawy. '
    },
    {
      name: 'q3',
      label: 'Projekt nie narusza norm, standardów oraz przepisów technicznych',
      type: 'radio', not_applicable: false,
      tooltip: 'Sprawdź, czy są określone jakieś szczegółowe wytyczne (oprócz przepisów prawa) dotyczące realizacji zadań. Upewnij się, że opisane w projekcie działania są możliwe do realizacji bez naruszenia tych zapisów. Np. Standardy dostępności dla m.st. Warszawy, Standardy projektowe i wykonawcze dla systemu rowerowego w m.st. Warszawie.<br /><br />Jeśli nie ma żadnych obowiązujących wytycznych dotyczących danego projektu, zaznacz „spełniono” na karcie oceny merytorycznej.'
    },
    {
      name: 'q4',
      label: 'Projekt nie jest sprzeczny z dokumentami programującymi rozwój m.st. Warszawy niebędącymi aktami prawa miejscowego, w tym strategiami, programami oraz Wieloletnią Prognozą Finansową w zakresie zamieszczonych w niej przedsięwzięć',
      type: 'radio', not_applicable: false,
      tooltip: 'Sprawdź, czy działania opisane w projekcie zostały ujęte w którymś z dokumentów dostępnych na stronie: <a href="https://bip.warszawa.pl/Menu_przedmiotowe/programy_strategie_plany/default.htm">https://bip.warszawa.pl/Menu_przedmiotowe/programy_strategie_plany/default.htm</a>. Projekt nie może być sprzeczny z zapisami tych dokumentów oraz planowanymi zadaniami, zamieszczonymi w Wieloletniej Prognozie Finansowej.<br /><br />Jeżeli działania opisane w projekcie nie są ujęte w żadnym z powyższych dokumentów, to projekt spełnia to kryterium oceny.'
    },
    {
      name: 'q5',
      label: 'Nie dojdzie do naruszenia praw osób trzecich, w tym praw autorskich i praw zależnych',
      type: 'radio2',
      fields: [
        { name: 'q5a', label: 'a. projekt nie narusza praw autorskich', not_applicable: true },
        { name: 'q5b', label: 'b. do projektu została dołączona zgoda autora na wykorzystanie utworu (jeżeli jest wymagana)', not_applicable: true }
      ],
      tooltip: 'Upewnij się, że realizacja projektu nie naruszy praw osób trzecich. W przypadku projektów, które przewidują korzystanie z utworu, w rozumieniu ustawy z dnia 4 lutego 1994 r. o prawie autorskim i prawach pokrewnych, na etapie oceny powinna zostać zawarta umowa o przeniesie na m.st. Warszawę autorskich praw majątkowych lub praw zależnych do utworu, pod warunkiem wyboru projektu.<br /><br />Samo zgłoszenie projektu (formularz zgłoszeniowy) nie jest utworem, a więc projektodawca nie musi dostarczać zgody autora utworu przy zgłaszaniu projektu. Ale np. zdjęcia, plany i projekty umieszczona w załączniku są utworami i powinna być dołączona stosowna zgoda.'
    },
    {
      name: 'q6',
      label: 'Brak wskazania potencjalnego wykonawcy, trybu jego wyboru lub znaków towarowych',
      type: 'radio', not_applicable: false,
      tooltip: 'Sprawdź, czy w treści projektu autor nie wskazał potencjalnego wykonawcy, trybu jego wyborów lub znaków towarowych. Autor opisuje, co chciałby, żeby zostało zrealizowane, a nie kto to zrealizuje. <br/><br/>Autor projektu może zostać wykonawcą projektów, ale musi być wybrany zgodnie obowiązującymi przepisami (np. firma, w której pracuje może wziąć udział w przetargu, może odpowiedzieć na zapytanie ofertowe itd.).'
    },
    {
      name: 'q7',
      label: 'M.st. Warszawa posiada tytuł prawny do dysponowania nieruchomością, na której projekt będzie realizowany',
      type: 'radio', not_applicable: false,
      tooltip: 'Upewnij się, że m.st Warszawa posiada prawo do realizacji działań we wskazanej lokalizacji. <br /><br />Realizacja jest możliwa, jeśli:<ul><li>teren jest własnością m.st. Warszawy i nie został oddany we władanie innym podmiotom,</li><li>teren stanowi własność innego podmiotu (np. Skarbu Państwa), ale m.st. Warszawa dysponuje formą władania tym terenem odpowiadającą profilowi zadania opisanemu w projekcie. </li></ul><br />Realizacja nie jest możliwa, jeśli:<br /><ul><li>teren stanowi własność m.st. Warszawy, ale został on oddany w użytkowanie wieczyste spółdzielni lub podmiotowi prywatnemu,</li><li>teren stanowi własność m.st. Warszawy, ale w miejscu realizacji projektu została ustanowiona służebność przesyłu tj. na terenie są urządzenia służące np. do przesyłu energii,</li><li>nieruchomość stanowi własność m.st. Warszawy, ale została oddana w najem lub wydzierżawiona.</li></ul><br />Upewnij się, że wskazany teren nie jest objęty roszczeniami. Jeśli jest, to naruszone zostaje kryterium 1. Projekt nie narusza przepisów prawa powszechnie obowiązującego, w tym aktów prawa miejscowego, ze względu na ewentualną niegospodarność i naruszenie dyscypliny finansów publicznych.<br />Polski system prawa określa m.in. następujące formy władania nieruchomością:<ul><li>prawo rzeczowe (np.: własność, współwłasność, użytkowanie wieczyste),</li><li>trwały zarząd,</li><li>ograniczone prawo rzeczowe (np.: służebność),</li><li>stosunek zobowiązaniowy (np.: najem, dzierżawa, użyczenie).</li></ul>'
    },
    {
      name: 'q8',
      label: 'Projekt jest możliwy do zrealizowania we wskazanej w zgłoszeniu projektu lokalizacji, w tym czy realizacja projektu nie koliduje z realizowanymi przedsięwzięciami m.st. Warszawy',
      type: 'radio', not_applicable: false,
      tooltip: 'Sprawdź, czy w określonej lokalizacji miasto może realizować działania opisane w projekcie np. czy nie ma jakiejś infrastruktury podziemnej, która by to uniemożliwiała. Upewnij się, że w danej lokalizacji nie są planowane lub prowadzone jakieś działania np. remont ulicy, które nie zakończą się w roku realizacji i będą kolidowały z działaniami opisanymi w projekcie.'
    },
    {
      name: 'q9',
      label: 'Realizacja projektu we wskazanej w zgłoszeniu projektu lokalizacji nie naruszy gwarancji udzielonej m.st. Warszawie przez wykonawcę na istniejącą w tej lokalizacji infrastrukturę',
      type: 'radio', not_applicable: true,
      tooltip: 'Sprawdź, czy we wskazanej w projekcie lokalizacji były wcześniej prowadzone działania (np. remont chodnika lub przebudowa ulicy), które są objęte gwarancją. Upewnij się, że realizacja projektu nie naruszy tej gwarancji.'
    },
    {
      name: 'q10',
      label: 'Dostępne na rynku technologie umożliwiają realizację projektu',
      type: 'radio', not_applicable: false
    },
    {
      name: 'q11',
      label: 'Projekt nie zakłada wykonania wyłącznie dokumentacji projektowej',
      type: 'radio', not_applicable: false
    },
    {
      name: 'q12',
      label: 'W przypadku, gdy do realizacji projektu są wymagane decyzje administracyjne, pozwolenia, zezwolenia, opinie lub inne dokumenty techniczne, czy ich uzyskanie jest możliwe i pozwoli zrealizować projekt w trakcie roku budżetowego',
      type: 'radio', not_applicable: true
    },
    {
      name: 'q13',
      label: 'Projekt jest możliwy do zrealizowania w trakcie jednego roku budżetowego',
      type: 'radio', not_applicable: false
    },
    {
      name: 'q14',
      label: 'Projekt nie wiąże się z koniecznością wykonania kolejnych etapów realizacji zadania w latach kolejnych',
      type: 'radio', not_applicable: false
    },
    {
      name: 'q15',
      label: 'Mieszkańcy Warszawy mogą korzystać z projektu nieodpłatnie',
      type: 'radio', not_applicable: false
    },
    {
      name: 'q16',
      label: 'W przypadku projektów infrastrukturalnych, remontowych lub polegających na zakupie sprzętu lub urządzeń - minimalna dostępność projektu wynosi co najmniej 25 godzin tygodniowo, pomiędzy godz. 6:00-22:00, z uwzględnieniem soboty lub niedzieli',
      type: 'radio', not_applicable: true
    },
    {
      name: 'q17',
      label: 'W przypadku, gdy projekt skierowany jest do ograniczonej grupy odbiorców - wskazuje zasady rekrutacji, w tym sposób informowania o rekrutacji, termin jej rozpoczęcia i zakończenia oraz kryteria naboru',
      type: 'radio', not_applicable: true
    },
    {
      name: 'estimate',
      label: 'Kosztorys realizacji projektu (z uwzględnieniem kosztów oznakowania graficznego projektów realizowanych w ramach budżetu obywatelskiego oraz kosztami eksploatacji w roku wykonania)',
      type: 'text',
      extra_hint: 'z uwzględnieniem kosztów oznakowania graficznego projektów realizowanych w ramach budżetu obywatelskiego oraz kosztami eksploatacji w roku wykonania'
    },
    {
      name: 'q19',
      label: 'Utrzymanie faktycznych kosztów realizacji w ramach limitu wartości pojedynczego projektu',
      type: 'radio', not_applicable: false
    }
  ]
end

