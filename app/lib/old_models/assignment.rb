# frozen_string_literal: true

class OldModels::Assignment
  include Virtus.model

  attribute :verifierId, Integer
  attribute :subCoordinatorId, Integer
  attribute :officeId, Integer
  attribute :unitId, Integer
end

