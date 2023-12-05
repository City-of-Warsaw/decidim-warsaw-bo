# frozen_string_literal: true

class OldModels::History
  include Virtus.model

  attribute :userId, Integer
  attribute :createTime, String
  attribute :type, Integer
  attribute :data, String

  def project_version
    OldModels::ProjectVersion.new JSON.parse(data)
  end

end

