# frozen_string_literal: true

class OldModels::Recipient
  include Virtus.model

  attribute :id, Integer
  attribute :name, String

end

