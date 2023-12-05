# frozen_string_literal: true

class OldModels::CreatorAgreementFile
  include Virtus.model

  attribute :fileName, String
  attribute :originalName, String
end

