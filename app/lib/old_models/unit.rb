# frozen_string_literal: true

class OldModels::Unit
  include Virtus.model

  attribute :id, Integer
  attribute :name, String

  def old_type
    'unit'
  end
end

