# frozen_string_literal: true

module Decidim::Projects
  # MeritoricalEvaluation is a Type of Evaluation model.
  # It is the second Evaluation that is made on the project, one that finishes Evaluation process.
  class MeritoricalEvaluation < Evaluation
    # Public: meritorical evaluation documents
    #
    # syntactic sugar for attachments
    def documents
      attachments
    end

    # Public: project implementation effects
    #
    # returns String - if it was provided
    def project_implementation_effects
      details["project_implementation_effects"].presence || nil
    end

    # Public: negative reason of evaluation
    #
    # returns String - if it was provided
    def negative_verification_reason
      details["result_description"].presence || nil
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
      'karta_oceny_merytorycznej'
    end

    def pdf_template_name
      'decidim/projects/admin/meritorical_evaluations/show.pdf.erb'
    end
  end
end
