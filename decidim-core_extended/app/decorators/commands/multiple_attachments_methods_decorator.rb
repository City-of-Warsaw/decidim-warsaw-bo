# frozen_string_literal: true

Decidim::MultipleAttachmentsMethods.class_eval do

  private

  # uzywane do wgrywania zalacznikow w ocenach, ustawia nazwe pliku wg wymagan
  def build_evaluation_attachments(eval_file_type)
    @documents = []
    @form.add_documents.each do |file|
      @documents << Decidim::Attachment.new(
        title: { I18n.locale => @attached_to.file_name(file.tempfile) },
        attached_to: @attached_to || documents_attached_to,
        new_file_name: @attached_to.file_name(file.tempfile),
        file: file,
        eval_file_type: eval_file_type
      )
    end
  end

end
