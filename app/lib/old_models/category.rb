# frozen_string_literal: true

class OldModels::Category
  include Virtus.model

  attribute :id, Integer
  attribute :name, String

end

