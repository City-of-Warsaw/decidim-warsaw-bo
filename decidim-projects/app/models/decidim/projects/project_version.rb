# frozen_string_literal: true

# visible_type:
# 1 – Publiczna,
# 2 - Tylko dla administratora – niepubliczny,
# 3 – Oczekuje na zatwierdzenie,
# 4 – Projekt realizowany,
# -1 – Kopia robocza
# t.integer :visible_type, default: -1
# t.boolean :visible, default: false

module Decidim::Projects
  # Project version is a PaperTrail versioning model dedicated for Projects
  class ProjectVersion < PaperTrail::Version
    self.table_name = :project_versions
    self.sequence_name = :project_versions_id_seq

    scope :visible, -> { where(visible: true) }
  end
end
