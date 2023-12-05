# frozen_string_literal: true

class OldModels::Verification
  include Virtus.model

  attribute :formalResult, String       # variables: nil, "", "1"/"positive", "2"/"negative"
  attribute :meritResult, String        # variables: nil, "", "1"/"positive", "2"/"negative"
  attribute :reevaluationResult, String # variables: nil, "", "1"/"positive", "2"/"negative"
  attribute :attachments, {}

  def formal_attachments
    attachments['formal'].presence || []
  end

  def merit_attachments
    attachments['merit'].presence || []
  end

  def reevaluation_attachments
    attachments['reevaluation'].presence || []
  end

  def formal_result_true?
    formalResult == "1" || formalResult == "pozytywny"
  end

  def merit_result_true?
    meritResult == "1" || meritResult == "pozytywny"
  end

  def reevaluation_result_true?
    reevaluationResult == "1" || reevaluationResult == "pozytywny"
  end

  def formal_result_details
    formalResult.blank? ? {} : { "result": formal_result_true? ? 1 : 2 }
  end

  def merit_result_details
    meritResult.blank? ? {} : { "result": merit_result_true? ? 1 : 2 }
  end

  def reevaluation_result_details
    reevaluationResult.blank? ? {} : { "result": reevaluation_result_true? ? 1 : 2 }
  end
end
