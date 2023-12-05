# frozen_string_literal: true

class OldModels::MapPin
  include Virtus.model

  attribute :lat, Decimal
  attribute :lng, Decimal
end

