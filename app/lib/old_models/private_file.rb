# frozen_string_literal: true

class OldModels::PrivateFile
  include Virtus.model

  attribute :fileName, String
  attribute :originalName, String
end

