class AddTemplateToEndorsementSettings < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        file_path =  File.join(Rails.root, 'app/assets/images/logo.png')
        Decidim::ParticipatoryProcess.all.each do |process|
          endorsement_list = Decidim::ProcessesExtended::EndorsementListSetting.create!(decidim_participatory_process_id: process.id,
                                                                                        header_description: ' Lista poparcia dla projektu<br />do budżetu obywatelskiego w m.st. Warszawie na rok %{process_year}',
                                                                                        footer_description: '<p><strong>Objaśnienia:</strong>
      </p>
      <p>Lista powinna zawierać:</p>
      <ol><li>
          w przypadku projektów na poziomie dzielnicowym,
          <strong>podpisy co najmniej 20 mieszkańców dzielnicy m.st.Warszawy, w
            której zgłaszany jest projekt</strong>
          lub
        </li><li>
          w przypadku projektów na poziomie ogólnomiejskim,
          <strong>podpisy co najmniej 40 mieszkańców m.st.Warszawy</strong>
          popierających projekt do budżetu obywatelskiego.
        </li></ol>
      <p>
        Do liczby mieszkańców popierających projekt nie wlicza się
        projektodawców danego projektu
      </p>')
          File.open(file_path) do |file|
            endorsement_list.image_header.attach(io: file, filename: "logo.png")
          end
        end
      end

      dir.down do
        Decidim::ProcessesExtended::EndorsementListSetting.destroy_all
      end
    end
  end
end
