# frozen_string_literal: true

module FormalEvaluationFieldsDefinition
  FORMAL_FIELDS = [
    { name: :submission_on_time,
      translation: '1. Zgłoszenie projektu w terminie', value: 1, applicable: nil, correctable: false, corrected: nil,
      negative_translation: 'Projekt nie został zgłoszony w terminie'
    },
    { name: :less_than_3_authors, translation: '2. Nie więcej niż 3 autorów', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Projekt ma więcej niż 3 autorów'
    },
    { name: :authors_from_warsaw, translation: '3. Autorzy są mieszkańcami Warszawy', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Autorzy nie są mieszkańcami Warszawy'
    },
    { name: :qq1, translation: '4. Zgłoszenie projektu zawiera', value: nil, applicable: nil, correctable: false, corrected: nil,
      negative_translation: ''
    },
    { name: :with_title, translation: 'a. Nazwę', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera nazwy'
    },
    { name: :with_description, translation: 'b. Opis', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera opisu'
    },
    { name: :with_level, translation: 'c. Wskazanie poziomu', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera wskazania poziomu'
    },
    { name: :with_localization, translation: 'd. Lokalizację', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera lokalizacji'
    },
    { name: :with_argumentation, translation: 'e. Uzasadnienie realizacji', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera uzasadnienia realizacji'
    },
    { name: :with_category, translation: 'f. Wskazanie kategorii tematycznej', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie wskazuje kategorii tematycznych'
    },
    { name: :with_recipients, translation: 'g. Wskazanie potencjalnych odbiorców', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie wskazuje potencjalnych odbiorców'
    },
    { name: :with_budget, translation: 'h. Szacunkowy koszt realizacji', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera szacunkowego kosztu realizacji'
    },
    { name: :with_authors, translation: 'i. Kompletne dane projektodawców (imię i nazwisko, adres zamieszkania, kontakt)', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera kompletnych danych projektodawców'
    },
    { name: :with_signatures, translation: 'j. Podpisy', value: 1, applicable: true, correctable: true, corrected: false,
      negative_translation: 'Zgłoszenie projektu nie zawiera podpisów'
    },
    { name: :q1, translation: '5. Dołączenie listy poparcia', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Nie dołączono listy poparcia'
    },
    { name: :q2, translation: '6. Poprawne wypełnienie listy poparcia', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Lista poparcia nie została poprawnie wypełniona'
    },
    { name: :q3, translation: '7. Dołączenie zgody autora na wykorzystanie utworu', value: 1, applicable: true, correctable: true, corrected: false,
      negative_translation: 'NIe dołączono zgody autora na wykorzystanie utworu'
    },
    { name: :q4, translation: '8. Brak treści obraźliwych, obscenicznych, wulgarnych i społecznie nagannych', value: 1, applicable: nil, correctable: false, corrected: nil,
      negative_translation: 'Projekt zawiera nieodpowiednie treści'
    },
    { name: :q5, translation: '9. Projekt został przyporządkowany do właściwego poziomu', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Projekt został przyporządkowany do niewłaściwego poziomu'
    },
    { name: :q6, translation: '10. Zgodność nazwy projektu z jego treścią', value: 1, applicable: nil, correctable: true, corrected: false,
      negative_translation: 'Nazwa projektu nie odpowiada jego treści'
    }
  ]

  SECOND_DEPTH_FORMAL_FIELDS = %w[with_title with_description with_level with_localization with_argumentation with_category
                                  with_recipients with_budget with_authors with_signatures]
end

