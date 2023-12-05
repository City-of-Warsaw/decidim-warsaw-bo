# frozen_string_literal: true

class OldModels::TaskVerificationRecall
  include Virtus.model

  attribute :createTime, String # Date - 2021-02-01 12:47:54
  attribute :content, String
  attribute :attachments, []
end
