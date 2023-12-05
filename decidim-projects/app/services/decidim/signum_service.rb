# frozen_string_literal: true

require 'ostruct'

module Decidim
  class SignumService

    def initialize
      @login = ENV.fetch('WS_SIGNUM_LOGIN')
      @password = ENV.fetch('WS_SIGNUM_PASSWORD')
      @client = Savon.client(
        wsdl: ENV.fetch('WS_SIGNUM_WSDL'),
        adapter: :net_http,
        # Lower timeouts so these specs don't take forever when the service is not available.
        open_timeout: 10,
        read_timeout: 10,
        log: true
      )
      @client
    end

    # => urz_id => 5022060908280639785
    # return urz_id or nil
    def find_user_in_signum(user, dev_test = true)
      return if user.ad_name.blank?

      login_ad = "BZMW\\#{user.ad_name}"
      login_ad = 'BZMW\ext.skovalchuk' if Rails.env.development? && dev_test

      find_login_ad_in_signum(login_ad)
    end

    # return urz_id or nil
    def find_login_ad_in_signum(login_ad)
      return if login_ad.blank?

      ap "SZUKAM loginu find_login_ad_in_signum(#{login_ad})"
      message = { login: @login, haslo: @password, loginAD: login_ad }
      response = @client.call(:pobierz_dane_uzytkownika, message: message)
      # ap response
      result = response.body[:pobierz_dane_uzytkownika_response][:pobierz_dane_uzytkownika_result]
      ap 'result:'
      ap result
      if result[:status] == 'ERR'
        nil
      else
        dane_uzytkownika = result[:content][:dane_uzytkownika]
        signum_user = if dane_uzytkownika.is_a? Hash
                        dane_uzytkownika
                      else
                        dane_uzytkownika.find{ |e| e[:wygaszony] == false }
                      end
        signum_user[:id].to_s
      end
    rescue Net::ReadTimeout
      logger.debug "Brak polaczenia"
      nil
    end

    # rejestruje przychodzace pismo w SIGNUM
    # return response:
    # {
    #   :error=>nil,
    #   :lista_pism=>{
    #     :pismo_do_signum_out=>{
    #       :@spr_id=>"5023080213245146138",
    #       :@pis_id=>"5023080213245150840",
    #       :@znak_sprawy=>"",
    #       :@nr_kancelaryjny=>"AM-KO/25/23",
    #       :@kor_id=>"5023080213223910224",
    #       :@error=>"",
    #       :@informacja_dodatkowa=>"Nr identyfikacyjny DECIDIM: 4"
    # }}}
    def add_document_to_signum(urz_id:, temat:, author:, historia:, rodzaj_przesylki:, informacja_dodatkowa:, files: [])
      dataWplywu = DateTime.current.to_date.strftime("%F") # dataWplywu = "2022-09-28"
      message = {
        sXML: "
          <signumWS>
              <pismoDoSignum login='' urz_id='#{urz_id}' spr_id='' znakSprawy='' pis_id='' addSprIfNotExists='' jrwa='' gdzieMaTrafic='przychodzace'
          rodzajPrzesylki='#{rodzaj_przesylki}' wyslane='' nadajNrKancelaryjny='1' barcode='' dataWplywu='#{dataWplywu}' pot_numer='' nrPisma='' znakBezInicjalow=''>
                  <temat>#{temat}</temat>
                  <historia>#{historia}</historia>
                  <informacjaDodatkowa>#{informacja_dodatkowa}</informacjaDodatkowa>

                <!-- <zalacznik nazwaPliku='#{1}_testowy.pdf'>(Tutaj wstawiany jest załącznik w formacie base64)</zalacznik> -->

                  <korespondent kor_id=''>
                    <nazwisko>#{author.last_name}</nazwisko>
                    <imie>#{author.first_name}</imie>
                    <nazwaFirmy/>
                    <miasto>#{author.city}</miasto>
                    <kod>#{author.zip_code}</kod>
                    <ulica>#{author.street}</ulica>
                    <dom>#{author.street_number}</dom>
                    <lokal>#{author.flat_number}</lokal>
                    <regon/>
                    <nip/>
                  </korespondent>
              </pismoDoSignum>
          </signumWS>
        ",
        login: @login,
        haslo: @password
      }
      response = @client.call(:pismo_do_signum2, message: message)
      response.body[:pismo_do_signum2_response][:signum_ws_out]
    end

    # Tworzy sprawe do wprowadzonego juz pisma
    # @return: {
    #   :@spr_id=>"5023080213245146138",
    #   :@pis_id=>"5023080213245150840",
    #   :@znak_sprawy=>"AM.0632.4.2.2023.DKS",
    #   :@nr_kancelaryjny=>"", :@kor_id=>"5023080213223910224",
    #   :@error=>"", :@informacja_dodatkowa=>""
    # }
    def create_case(urz_id:, spr_id:, kor_id:, jrwa:)
      message = {
        sXML: "
          <signumWS>
            <pismoDoSignum login='' urz_id='#{urz_id}' spr_id='#{spr_id}' znakSprawy=''
                pis_id='' addSprIfNotExists='' jrwa='#{jrwa}' gdzieMaTrafic='wrealizacji' rodzajPrzesylki='' wyslane=''
                nadajNrKancelaryjny='' barcode='' dataWplywu='' nrKancelaryjny='' pot_numer='4' nrPisma='' znakBezInicjalow=''>
              <temat></temat>
              <historia>Założenie sprawy z pisma przychodzącego</historia>
              <informacjaDodatkowa></informacjaDodatkowa>
              <korespondent kor_id='#{kor_id}'></korespondent>
            </pismoDoSignum>
          </signumWS>
        ",
        login: @login,
        haslo: @password
      }
      response = @client.call(:pismo_do_signum2, message: message)
      response.body[:pismo_do_signum2_response][:signum_ws_out]
    end

    # Metoda sluzy do pobrania wszystkich pism dotyczących w sprawie
    # @param idUrzednika - który posiada daną sprawę
    # @param idSprawy - id szukanej sprawy urzednika
    def get_all_documents(urz_id:, spr_id:)
      message = {
        login: @login,
        haslo: @password,
        loginUrzednika: nil,
        idUrzednika: urz_id,
        idSprawy: spr_id,
        znakSprawy: nil
      }

      response = @client.call(:pobierz_pisma_w_sprawie_z_signum2, message: message)
      response.body[:pobierz_pisma_w_sprawie_z_signum2_response][:pobierz_pisma_w_sprawie_z_signum2_result]
    end

    # Zwraca liste dostepnych operacji w WebService
    def operations
      @client.operations
    end

    def register_project_to_signum(urz_id:, project:, user:)
      response = add_document_to_signum(
        urz_id: urz_id,
        temat: "#{project.esog_number} - #{project.title}",
        author: project.creator_author,
        historia: "Rejestracja pisma inicjującego",
        rodzaj_przesylki: '27',
        informacja_dodatkowa: "Nr identyfikacyjny DECIDIM: #{project.id}"
      )
      return if response[:error] # => nil to ok, nie przetwazamy dalej jesli jes terror

      data = response[:lista_pism][:pismo_do_signum_out]
      spr_id = data[:@spr_id]
      nr_kancelaryjny = data[:@nr_kancelaryjny]
      kor_id = data[:@kor_id]

      response = create_case(urz_id: urz_id, spr_id: spr_id, kor_id: kor_id, jrwa: 0632)
      # response[:error] => nil
      data = response[:lista_pism][:pismo_do_signum_out]
      znak_sprawy = data[:@znak_sprawy]

      project.update(
        signum_spr_id: spr_id,
        signum_kor_id: kor_id,
        signum_nr_kancelaryjny: nr_kancelaryjny,
        signum_znak_sprawy: znak_sprawy,
        signum_registered_at: DateTime.current,
        signum_registered_by_user_id: user.id
      )
    end

    def register_study_note_to_signum(urz_id:, study_note:, user:)
      author = OpenStruct.new(
        first_name: study_note.first_name,
        last_name: study_note.last_name,
        organization_name: study_note.organization_name,
        city: study_note.city,
        zip_code: study_note.zip_code,
        street: study_note.street,
        street_number: study_note.street_number,
        flat_number: study_note.flat_number
      )
      response = add_document_to_signum(
        urz_id: urz_id,
        temat: "Uwaga do studium Decidim – #{study_note.id}",
        author: author,
        historia: "Złożenie nowej uwagi do projektu Studium",
        rodzaj_przesylki: '66', # systemy dziedzinowe
        informacja_dodatkowa: "Nr identyfikacyjny DECIDIM: #{study_note.id}"
      )
      return if response[:error] # => nil to ok, nie przetwazamy dalej jesli jes terror

      data = response[:lista_pism][:pismo_do_signum_out]
      spr_id = data[:@spr_id]
      pis_id = data[:@pis_id]
      nr_kancelaryjny = data[:@nr_kancelaryjny]
      kor_id = data[:@kor_id]
      response = create_case(urz_id: urz_id, spr_id: spr_id, kor_id: kor_id, jrwa: '0632')
      data = response[:lista_pism][:pismo_do_signum_out]
      znak_sprawy = data[:@znak_sprawy]
      barcode = "#{pis_id}0" # w Signum barcode jest tworzone automatycznie o ile nie bylo przekazane w parametrach

      study_note.update(
        signum_barcode: barcode,
        signum_spr_id: spr_id,
        signum_kor_id: kor_id,
        signum_nr_kancelaryjny: nr_kancelaryjny,
        signum_znak_sprawy: znak_sprawy,
        signum_registered_at: DateTime.current,
        signum_registered_by_user_id: user&.id
      )
    end
  end
end
