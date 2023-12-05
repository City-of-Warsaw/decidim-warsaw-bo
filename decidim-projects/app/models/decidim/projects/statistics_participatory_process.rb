# frozen_string_literal: true

module Decidim::Projects
  class StatisticsParticipatoryProcess < ApplicationRecord
    belongs_to :scope,
               class_name: "Decidim::Scope",
               foreign_key: :scope_id
    belongs_to :participatory_process,
               class_name: "Decidim::ParticipatoryProcess",
               foreign_key: :participatory_process_id

  end
end
