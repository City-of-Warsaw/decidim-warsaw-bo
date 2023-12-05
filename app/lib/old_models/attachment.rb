# frozen_string_literal: true

class OldModels::Attachment
  include Virtus.model

  attribute :url, String # => /uploads/tasks/1576499430_zalacznik_0_143_21954.jpg
  attribute :originalName, String
end

