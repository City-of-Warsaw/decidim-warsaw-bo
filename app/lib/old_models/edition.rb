# frozen_string_literal: true

class OldModels::Edition
  include Virtus.model

  attribute :id, Integer
  attribute :name, String

  def year
    name.match(/[a-z ]([0-9]{4})/)[1].to_i
  end
end

