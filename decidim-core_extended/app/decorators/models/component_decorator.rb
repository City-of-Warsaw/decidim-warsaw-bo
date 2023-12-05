# frozen_string_literal: true

Decidim::Component.class_eval do
  belongs_to :process,
              class_name: "Decidim::ParticipatoryProcess",
              foreign_key: :participatory_space_id,
              optional: true

  belongs_to :published_process, -> { published.where(decidim_components: { participatory_space_type: 'Decidim::ParticipatoryProcess' }) },
             class_name: "Decidim::ParticipatoryProcess",
             foreign_key: :participatory_space_id,
             optional: true
end
