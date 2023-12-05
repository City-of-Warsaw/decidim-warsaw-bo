# frozen_string_literal: true

class OldModels::District
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :editionId, Integer

end

