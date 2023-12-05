# frozen_string_literal: true

class OldModels::Cocreator
  include Virtus.model

  attribute :id, Integer
  attribute :email, String
  attribute :firstName, String
  attribute :lastName, String
  attribute :phoneNo, String
  attribute :userId, Integer

end

