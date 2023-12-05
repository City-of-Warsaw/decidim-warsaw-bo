# frozen_string_literal: true

module Decidim::Projects
  # Evaluation is a model used to evaluate projects in admin panel.
  class Evaluation < ApplicationRecord
    include Decidim::HasAttachments

    belongs_to :project,
               class_name: "Decidim::Projects::Project",
               foreign_key: :project_id
    belongs_to :user,
               class_name: "Decidim::User",
               foreign_key: :user_id
    has_many :documents, # zalaczniki
             class_name: "Decidim::Attachment",
             dependent: :destroy,
             inverse_of: :attached_to,
             foreign_key: :attached_to_id

    delegate :organization, to: :project

    # Public: Result
    #
    # 1 - positive (pozytywna)
    # 2 - negative (negatywna)
    def result
      details["result"].presence || nil
    end

    # result is set as:
    # - 1 OR 2 for Formal Evaluation
    # - 1 OR 2 for Meritorical Evaluation
    # - 1 OR 2 for Reevaluation IN MIGRATION
    # - true OR false for Reevaluation
    # - nil if it was not yet set
    def positive_result?
      result == 1 || result == true
    end

    # result is set as:
    # - 1 OR 2 for Formal Evaluation
    # - 1 OR 2 for Meritorical Evaluation
    # - 1 OR 2 for Reevaluation IN MIGRATION
    # - true OR false for Reevaluation
    # - nil if it was not yet set
    def negative_result?
      result == 2 || result == false
    end

    # Public: name generated pdf file without extension
    def pdf_filename
      raise "No defined method!"
    end

    # Public: name generated template
    def pdf_template_name
      raise "No defined method!"
    end

    # Public: name for generated and uploaded files
    #
    # Method saves the name of a file according to the given template (pl)
    #
    # returns String
    def file_name(file, scan = true)
      edition_year = project.component.participatory_space.edition_year
      esog_number = project.esog_number
      file_number = documents.size + 1
      variant = scan ? "skan" : "dostepna"
      "#{pdf_filename}_#{edition_year}_#{esog_number}_#{file_number}_#{variant}#{File.extname(file)}"
    end

    # Public: saving evaluation to pdf
    #
    # Method can be called in console:
    # Decidim::Projects::MeritoricalEvaluation.last.save_pdf_to_file
    # Decidim::Projects::FormalEvaluation.last.save_pdf_to_file
    # Decidim::Projects::Evaluation.last.save_pdf_to_file
    def save_pdf_to_file
      pdf_html = ActionController::Base.new.render_to_string(
        template: pdf_template_name,
        locals: { '@evaluation': self, '@form': Decidim::Projects::Admin::ReevaluationForm.new },
        layout: nil)
      pdf_file = WickedPdf.new.pdf_from_string(pdf_html)

      tempfile = Tempfile.new([pdf_filename, '.pdf'], Rails.root.join('tmp'))
      tempfile.binmode
      tempfile.write pdf_file
      tempfile.close

      File.open(tempfile.path) do |file|
        self.documents << Decidim::Attachment.new(
          new_file_name: file_name(file, false),
          title: { I18n.locale => file_name(file, false) },
          attached_to: self, file: file,
          eval_file_type: "available")
      end

      tempfile.unlink
    end
  end
end
