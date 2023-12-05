# frozen_string_literal: true

module Decidim::Projects
  # ReevaluationEvaluation is a Type of Evaluation model.
  # It is the third Evaluation that is made on the project, one that finishes Reevaluation process.
  class ReevaluationEvaluation < Evaluation

    def documents
      attachments
    end

    def project_implementation_effects
      details["positive_reevaluation_body"].presence || nil
    end

    def negative_verification_reason
      details["negative_reevaluation_body"].presence || nil
    end

    def pdf_filename
      'karta_ponownej_oceny'
    end

    def pdf_template_name
      'decidim/projects/admin/reevaluations/show.pdf.erb'
    end

    # Propozycja wyniku rozpatrzenia odwołania
    def reevaluation_result_proposition
      details["reevaluation_result"]
    end

    def positive_result_proposition?
      reevaluation_result_proposition == 1
    end

    def negative_result_proposition?
      reevaluation_result_proposition == 2
    end

    # zatwierdzenie oceny wymaga ustawienia wyniku oceny, osoby i daty potwierdzenia oceny
    def can_be_approved?
      details["result"].present? && details["reevaluation_card_approve_date"].present? && details["reevaluation_card_approve_name"].present?
    end
  end
end
