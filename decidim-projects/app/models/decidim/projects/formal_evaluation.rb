# frozen_string_literal: true

module Decidim::Projects
  # FormalEvaluation is a Type of Evaluation model.
  # It is the first Evaluation that is made on the project.
  class FormalEvaluation < Evaluation
    # Public: formal evaluation documents
    #
    # syntactic sugar for attachments
    def documents
      attachments
    end

    # Public: negative reason of evaluation
    #
    # returns String - if evaluation result is negative
    def negative_verification_reason
      'Niespełnione kryteria oceny formalnej' if negative_result?
    end

    # Public: negative reason of evaluation for export file.
    #
    # Method returns list of all the reasons why formal evaluation was negative.
    #
    # returns String
    def negative_reasons_for_xls
      FormalEvaluationFieldsDefinition::FORMAL_FIELDS.map do |ff|
        if details["#{ff[:name]}_negative_reason"].present?
          details["#{ff[:name]}_negative_reason"]
        end
      end.compact.join(', ')
    end

    # Public: polish status
    #
    # field - String or Symbol
    #
    # returns String - polish version
    def status(field)
      if details[field] == 1
        'spełniono'
      elsif details[field] == 2
        'nie spełniono'
      elsif details[field] == 3
        'nie dotyczy'
      end
    end

    def pdf_filename
      'karta_oceny_formalnej'
    end

    def pdf_template_name
      'decidim/projects/admin/formal_evaluations/show.pdf.erb'
    end
  end
end
