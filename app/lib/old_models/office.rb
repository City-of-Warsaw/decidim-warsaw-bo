# frozen_string_literal: true

class OldModels::Office
  include Virtus.model

  attribute :id, Integer
  attribute :name, String

  def old_type
    'office'
  end
end

