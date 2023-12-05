# frozen_string_literal: true

class OldModels::RealizationHistory
  include Virtus.model

  attribute :userId, Integer
  attribute :createTime, String
  attribute :data, String

  def costVerified
    _data['costVerified']
  end

  def realizedBy
    _data['realizedBy']
  end

  def realizationDescription
    _data['realizationDescription']
  end

  def modifiedRealization
    _data['modifiedRealization']
  end


  def _data
    @_data ||= JSON.parse(data)
  end
end

