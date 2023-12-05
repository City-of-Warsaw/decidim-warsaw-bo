# frozen_string_literal: true

module Importers
  class BaseMigrationPlan

    def call
      # 2023
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2023.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).call } # => .. / 2751
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_all_verifications } # 10 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_all_attachments } # 30 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_realizations } # 0
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_cocreators } # 1
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2023).import_verification_recalls }

      # 2022
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2022.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).call } # => / 3034
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_all_verifications } # 10min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_all_attachments } # 30 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_realizations } # 7, dla 25045 brak pliku 'archive/images/1655214648_foto_25045_389.jpg'
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_cocreators } # 1
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2022).import_verification_recalls }

      # 2021
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2021.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).call } # => local 17 min / 2813, attachements: 3,3 min, verification_attachments: 8 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_all_verifications } # 10
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_all_attachments } # 22 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_realizations } # 10 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_cocreators } # 1
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2021).import_verification_recalls }

      # 2020
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2020.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).call } # => serv 29 min / 2849
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_all_verifications } # 10
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_all_attachments } # 25 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_realizations } # => 10 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_cocreators } # 1
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2020).import_verification_recalls }

      # 2019
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2019.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).call } # => / 3176
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_all_verifications } # 10 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_all_attachments } # 30 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_realizations } # 20 min TST?
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_cocreators } # 1
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2019).import_verification_recalls }

      # 2018
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2018.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).call } # => / 3924 60 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_all_verifications } # 7,5min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_all_attachments } # 31 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_realizations } # 16min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_cocreators }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2018).import_verification_recalls }

      # 2017
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2017.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).call } # => serv 12 min / 3419, local 10 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_all_verifications } # 10 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_all_attachments } # => 25 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_realizations } # 15 min, 2 Bledy dla old_id: 5178, 4926, 2x 4394
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_cocreators }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2017).import_verification_recalls }

      # 2016
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2016.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).call } # => serv 9 min/ 2333
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_all_verifications } # => 1 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_all_attachments } # => 2
      Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_realizations } # => 1 min # rollback w plikach dla "index: 568, old_id: 8370"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_cocreators }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2016).import_verification_recalls }

      # 2015
      i = Importers::ProjectsImporter.new "task-list-last/task-list-v1-editions-2015.json"
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).call } # => local 2 min /1398
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_all_verifications } # => 0
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_all_attachments } # => 1 min
      Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_realizations } # 1 min
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_cocreators }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_creator_agreements }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_private_files }
      # Benchmark.realtime { Importers::ProjectsImporter.new(2015).import_verification_recalls }
    end
  end
end
