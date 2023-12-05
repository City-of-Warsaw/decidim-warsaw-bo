# frozen_string_literal: true

class OldModels::Region
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
end

