# frozen_string_literal: true

module Decidim
  class ScopeBudgetSerializer < ActiveModel::Serializer

    attributes :id,
               :parentId,
               :name,
               :budget,
               :votingBudget

    def parentId
      object.decidim_participatory_process_id
    end

    def name
      object.scope.name['pl']
    end

    def budget
      object.budget_value
    end

    def votingBudget
      object.max_proposal_budget_value
    end

  end
end
