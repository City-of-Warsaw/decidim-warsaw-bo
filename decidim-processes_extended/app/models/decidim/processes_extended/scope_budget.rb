# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    # ScopeBudget sets a budget limit for each scope
    class ScopeBudget < ApplicationRecord
      belongs_to :participatory_process,
                 foreign_key: "decidim_participatory_process_id",
                 class_name: "Decidim::ParticipatoryProcess"
                 # inverse_of: :participatory_processes

      belongs_to :scope,
                 foreign_key: "decidim_scope_id",
                 class_name: "Decidim::Scope"
    end
  end
end
