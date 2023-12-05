# frozen_string_literal: true

class OldModels::Realization
  include Virtus.model

  attribute :revoked, Boolean
  attribute :displayHomepage, Boolean
  attribute :realizedBy, String
  attribute :description, String # nie korzystamy z tego pola, tylko z historii
  attribute :state, Integer
  attribute :lastModifiedDate, String # nie korzystamy z tego pola, tylko z historii
  attribute :costVerified, Decimal
  attribute :image, [Hash]
  attribute :history, [OldModels::RealizationHistory]
end

