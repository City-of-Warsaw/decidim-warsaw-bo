class AddAdminCooauthorshipConfirmation < ActiveRecord::Migration[5.2]
  def change
    Decidim::AdminExtended::MailTemplate.create(
      name: 'Treść wiadomości e-mail dla współautora od Administratora z informacją o potwierdzeniu statusu współautora',
      subject: 'Budżet obywatelski - Zostałaś(-eś) potwierdzona(-y) jako współautor projektu',
      system_name: 'coauthorship_confirmation_admin',
      body: "
          <p>Szanowna Mieszkanko, Szanowny Mieszkańcu,</p>
          <p>zostałaś(-eś) potwierdzona(-y) jako współautor przez administratora serwisu.</p>

          <p>Jeśli potrzebujesz pomocy lub uważasz, że ten e-mail został wysłany do Ciebie przez pomyłkę, napisz na adres: bo@um.warszawa.pl.</p>
          <p>
          Z poważaniem
          Urząd m.st. Warszawy
          </p>
          "
    )
  end
end
