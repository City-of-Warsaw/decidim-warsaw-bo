# frozen_string_literal: true

module DecidimDictionaries
  def roles
    %w[koord podkoord weryf edytor admin]
  end

  # Lista dla komorek (Department) i dzielnic (Scope)
  # symnol  - symbol komorki
  # code    - kod dzielnicy
  def district_list
    [
      # { name: "Ogólnomiejski", symbol: "om" }, # ogolnomiejsci jest tworzony osobno poza slownikiem
      { name: "Bemowo",     symbol: "bem",      code: "bem" },
      { name: "Białołęka",  symbol: "BIA",      code: "bia" },
      { name: "Bielany",    symbol: "BIE",      code: "bie" },
      { name: "Mokotów",    symbol: "MOK",      code: "mok" },
      { name: "Ochota",     symbol: "OCH",      code: "och" },
      { name: "Praga-Południe", symbol: "pra_pld", code: "prapd" },
      { name: "Praga-Północ", symbol: "pra_pln", code: "prapln" },
      { name: "Rembertów",  symbol: "rem",      code: "rem" },
      { name: "Śródmieście", symbol: "sso",     code: "sro" },
      { name: "Targówek",   symbol: "TAR",      code: "tar" },
      { name: "Ursus",      symbol: "Urs",      code: "urs" },
      { name: "Ursynów",    symbol: "Ursyn",    code: "ursyn" },
      { name: "Wawer",      symbol: "WAW",      code: "waw" },
      { name: "Wesoła",     symbol: "WES",      code: "wes" },
      { name: "Wilanów",    symbol: "WIL",      code: "wil" },
      { name: "Włochy",     symbol: "WLO",      code: "wlo" },
      { name: "Wola",       symbol: "WOL",      code: "wol" },
      { name: "Żoliborz",   symbol: "zol",      code: "zol" }
    ]
  end

  def biura
    [
      { name: "Biuro Administracji i Spraw Obywatelskich", symbol: "ao" },
      { name: "Biuro Administracyjne", symbol: "ba" },
      { name: "Biuro Architektury i Planowania Przestrzennego", symbol: "am" },
      { name: "Biuro Audytu Wewnętrznego", symbol: "aw" },
      { name: "Biuro Bezpieczeństwa i Zarządzania Kryzysowego", symbol: "zk" },
      { name: "Biuro Cyfryzacji Miasta", symbol: "bc" },
      { name: "Biuro Długu i Restrukturyzacji Wierzytelności", symbol: "dr" },
      { name: "Biuro Edukacji", symbol: "be" },
      { name: "Biuro Funduszy Europejskich i Polityki Rozwoju", symbol: "fe" },
      { name: "Biuro Geodezji i Katastru", symbol: "bg" },
      { name: "Biuro Gospodarki Odpadami", symbol: "go" },
      { name: "Biuro Infrastruktury", symbol: "in" },
      { name: "Biuro Kadr i Szkoleń", symbol: "ks" },
      { name: "Biuro Kontroli ", symbol: "kw" },
      { name: "Biuro Księgowości i Kontrasygnaty", symbol: "kk" },
      { name: "Biuro Kultury", symbol: "ku" },
      { name: "Biuro Ładu Korporacyjnego", symbol: "lk" },
      { name: "Biuro Marketingu Miasta", symbol: "mm" },
      { name: "Biuro Mienia Miasta i Skarbu Państwa", symbol: "bm" },
      { name: "Biuro Ochrony Powietrza i Polityki Klimatycznej", symbol: "pk" },
      { name: "Biuro Ochrony Środowiska", symbol: "os" },
      { name: "Biuro Organizacji Urzędu", symbol: "ou" },
      { name: "Biuro Planowania Budżetowego", symbol: "pb" },
      { name: "Biuro Polityki Lokalowej", symbol: "pl" },
      { name: "Biuro Polityki Zdrowotnej", symbol: "pz" },
      { name: "Biuro Pomocy i Projektów Społecznych", symbol: "ps" },
      { name: "Biuro Prawne", symbol: "op" },
      { name: "Biuro Rady m.st. Warszawy", symbol: "rw" },
      { name: "Biuro Rozwoju Gospodarczego", symbol: "rg" },
      { name: "Biuro Sportu i Rekreacji", symbol: "sr" },
      { name: "Biuro Spraw Dekretowych", symbol: "sd" },
      { name: "Biuro Strategii i Analiz", symbol: "bs" },
      { name: "Biuro Stołecznego Konserwatora Zabytków", symbol: "kz" },
      { name: "Biuro Współpracy Międzynarodowej", symbol: "wm" },
      { name: "Biuro Zamówień Publicznych", symbol: "zp" },
      { name: "Biuro Zarządzania Ruchem Drogowym", symbol: "zr" },
      { name: "Biuro Zgodności", symbol: "bz" },
      { name: "Centrum Komunikacji Społecznej", symbol: "cks" },
      { name: "Centrum Obsługi Podatnika", symbol: "cop" },
      { name: "Gabinet Prezydenta", symbol: "gp" },
      { name: "Miejskie Centrum Sieci i Danych", symbol: "csd" }
    ]
  end

  def jednostki
    [
      { name: "Lasy Miejskie - Warszawa", symbol: "lm" },
      { name: "Zarząd Dróg Miejskich", symbol: "zdm" },
      { name: "Zarząd Mienia m.st. Warszawy", symbol: "zm" },
      { name: "Zarząd Oczyszczania Miasta", symbol: "zom" },
      { name: "Zarząd Transportu Miejskiego", symbol: "ztm" },
      { name: "Zarząd Zieleni m.st. Warszawy", symbol: "zzw" },
      { name: "Dzielnicowe Biuro Finansów Oświaty Wola", symbol: "dbfo_wol" },
      { name: "Ośrodek Pomocy Społecznej dla Dzielnicy Targówek", symbol: "ops_tar" },
      { name: "Ośrodek Pomocy Społecznej Rembertów", symbol: "ops_rem" },
      { name: "Ośrodek Sportu i Rekreacji Praga-Południe", symbol: "osir_pra_pld" },
      { name: "Ośrodek Sportu i Rekreacji w Dzielnicy Targówek", symbol: "osir_tar" },
      { name: "Ośrodek Sportu i Rekreacji w Dzielnicy Wola", symbol: "osir_wol" },
      { name: "Ośrodek Sportu i Rekreacji Wawer", symbol: "osir_waw" },
      { name: "Ośrodek Sportu i Rekreacji Żoliborz", symbol: "osir_zol" },
      { name: "Poradnia Psychologiczno-Pedagogiczna nr 5", symbol: "ppp5" },
      { name: "Stołeczne Biuro Turystyki", symbol: "sbt" },
      { name: "Ursynowskie Centrum Sportu i Rekreacji", symbol: "ucsir" },
      { name: "VII Ogród Jordanowski", symbol: "7oj" },
      { name: "Zakład Gospodarowania Nieruchomościami Bielany", symbol: "zgn_bie" },
      { name: "Zakład Gospodarowania Nieruchomościami Praga-Północ", symbol: "zgn_pra_pln" },
      { name: "Zakład Gospodarowania Nieruchomościami w Dzielnicy Mokotów", symbol: "zgn_mok" },
      { name: "Zakład Gospodarowania Nieruchomościami w Dzielnicy Ochota", symbol: "zgn_och" },
      { name: "Zakład Gospodarowania Nieruchomościami w Dzielnicy Targówek", symbol: "zgn_targ" },
      { name: "Zakład Gospodarowania Nieruchomościami w Dzielnicy Włochy", symbol: "zgn_wlo" },
      { name: "Zakład Gospodarowania Nieruchomościami w Dzielnicy Wola", symbol: "zgn_wol" },
      { name: "Zakład Gospodarowania Nieruchomościami Wawer", symbol: "zgn_waw" },
      { name: "Zarząd Praskich Terenów Publicznych", symbol: "zptp" }
    ]
  end
end