# frozen_string_literal: true

module Decidim::Projects
  module CustomAttachmentsMethods
    private

    # private method
    #
    # Parameters:
    #
    # project - Project
    # file    - file
    # img_alt - String - not required
    #
    # returns Hash - mapped attributes to create Attachment
    def attachment_attrs(project, file, img_alt = nil)
      {
        title: { I18n.locale => file.original_filename },
        attached_to: project || documents_attached_to,
        file: file,
        content_type: file.content_type,
        file_size: file.size,
        image_alt: img_alt
      }
    end

    # private method
    #
    # Parameters:
    #
    # project - Project
    #
    # builds internal documents for Project
    #
    # returns nothing
    def build_internal_documents_for(project)
      @internal_documents = []
      return unless @form.respond_to?(:add_internal_documents)
      return if @form.add_internal_documents.none?

      @form.add_internal_documents.each do |file|
        if project
          project.internal_documents << Decidim::Projects::InternalDocument.new(attachment_attrs(project, file))
        else
          @internal_documents << Decidim::Projects::InternalDocument.new(attachment_attrs(project, file))
        end
      end
    end

    # private method
    #
    # checking if internal documents are valid
    #
    # returns Boolean
    def internal_documents_invalid?
      @internal_documents.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each { |error| @form.errors.add(:add_internal_documents, error) }
        return true
      end

      false
    end

    # private method
    #
    # Parameters:
    #
    # project - Project
    #
    # builds endorsements for Project
    #
    # returns nothing
    def build_endorsements_for(project)
      @endorsements = []
      return unless @form.respond_to?(:add_endorsements)
      return if @form.add_endorsements.none?

      @form.add_endorsements.each do |file|
        if project
          project.endorsements << Decidim::Projects::Endorsement.new(attachment_attrs(project, file))
        else
          @endorsements << Decidim::Projects::Endorsement.new(attachment_attrs(project, file))
        end
      end
    end

    # private method
    #
    # checking if endorsements are valid
    #
    # returns Boolean
    def endorsements_invalid?(project: nil, max_files_num: 10)
      @endorsements.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each { |error| @form.errors.add(:add_endorsements, error) }
        return true
      end

      return false unless max_files_num

      if (project&.endorsements&.size.presence || 0) + @endorsements.size > max_files_num
        @form.errors.add(:add_endorsements, "Maksymalna liczba plików: #{max_files_num}")
        return true
      end

      false
    end

    # private method
    #
    # Parameters:
    #
    # project - Project
    #
    # builds consents for Project
    #
    # returns nothing
    def build_consents_for(project)
      @consents = []
      return unless @form.respond_to?(:add_consents)
      return if @form.add_consents.none?

      @form.add_consents.each do |file|
        if project
          project.consents << Decidim::Projects::Consent.new(attachment_attrs(project, file))
        else
          @consents << Decidim::Projects::Consent.new(attachment_attrs(project, file))
        end
      end
    end

    # private method
    #
    # checking if consents are valid
    #
    # returns Boolean
    def consents_invalid?(project: nil, max_files_num: 5)
      @consents.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each { |error| @form.errors.add(:add_consents, error) }
        return true
      end

      return false unless max_files_num

      if (project&.consents&.size.presence || 0) + @consents.size > max_files_num
        @form.errors.add(:add_consents, "Maksymalna liczba plików: #{max_files_num}")
        return true
      end

      false
    end

    # private method
    #
    # Parameters:
    #
    # project - Project
    #
    # builds files for Project
    #
    # returns nothing
    def build_files_for(project)
      @files = []
      return unless @form.respond_to?(:add_files)
      return if @form.add_files.none?

      @form.add_files.each do |file|
        if project
          project.files << Decidim::Projects::VariousFile.new(attachment_attrs(project, file))
        else
          @files << Decidim::Projects::VariousFile.new(attachment_attrs(project, file))
        end
      end
    end

    # private method
    #
    # checking if files are valid
    #
    # returns Boolean
    def files_invalid?(project: nil, max_files_num: 10)
      @files.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each { |error| @form.errors.add(:add_files, error) }
        return true
      end

      return false unless max_files_num

      if (project&.files&.size.presence || 0) + @files.size > max_files_num
        @form.errors.add(:add_files, "Maksymalna liczba plików: #{max_files_num}")
        return true
      end

      false
    end

    # private method
    #
    # Parameters:
    #
    # project - Project
    #
    # builds implementation photos for Project
    #
    # returns nothing
    def build_implementation_photos_for(project)
      @implementation_photos = []
      return unless @form.respond_to?(:add_implementation_photos)
      return if @form.add_implementation_photos.none?

      @form.add_implementation_photos.each do |file|
        processed_name = file.original_filename.gsub(' ', '').gsub('-', '').gsub('_', '')
        image_alt = @form.add_implementation_photos_alt[processed_name.to_sym].presence || nil
        imp_attrs = {
          project: project,
          file: file,
          image_alt: image_alt
        }

        if project
          project.implementation_photos << Decidim::Projects::ImplementationPhoto.new(imp_attrs)
        else
          @implementation_photos << Decidim::Projects::ImplementationPhoto.new(imp_attrs)
        end
      end
    end

    # private method
    #
    # checking if implementation photos are valid
    #
    # returns Boolean
    def implementation_photos_invalid?
      @implementation_photos.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each { |error| @form.errors.add(:add_implementation_photos, error) }
        return true
      end

      false
    end

    # private method
    #
    # removing selected attachments for project
    # - internal documents
    # - endorsements
    # - consents
    # - files
    # - implementation_photos
    #
    # returns nothing
    def remove_attachments(project)
      if @form.respond_to?(:remove_internal_documents)
        project.internal_documents.where(id: @form.remove_internal_documents).delete_all if @form.remove_internal_documents.any?
      end
      if @form.respond_to?(:remove_endorsements)
        project.endorsements.where(id: @form.remove_endorsements).delete_all if @form.remove_endorsements.any?
      end
      if @form.respond_to?(:remove_consents)
        project.consents.where(id: @form.remove_consents).delete_all if @form.remove_consents.any?
      end
      if @form.respond_to?(:remove_files)
        project.files.where(id: @form.remove_files).delete_all if @form.remove_files.any?
      end
      if @form.respond_to?(:remove_implementation_photos)
        project.implementation_photos.where(id: @form.remove_implementation_photos).destroy_all if @form.remove_implementation_photos.any?
      end
    end


    def attachments_to_remove(project)
      files_list_to_remove = {}
      if @form.respond_to?(:remove_internal_documents)
        files_list_to_remove.merge!("internal_documents": project.internal_documents.where(id: @form.remove_internal_documents).pluck(:id)) if @form.remove_internal_documents.any?
      end
      if @form.respond_to?(:remove_endorsements)
        files_list_to_remove.merge!("endorsements":  project.endorsements.where(id: @form.remove_endorsements).pluck(:id)) if @form.remove_endorsements.any?
      end
      if @form.respond_to?(:remove_consents)
        files_list_to_remove.merge!("consents": project.consents.where(id: @form.remove_consents).pluck(:id)) if @form.remove_consents.any?
      end
      if @form.respond_to?(:remove_files)
        files_list_to_remove.merge!("files": project.files.where(id: @form.remove_files).pluck(:id)) if @form.remove_files.any?
      end
      if @form.respond_to?(:remove_implementation_photos)
        files_list_to_remove.merge!("implementation_photos": project.implementation_photos.where(id: @form.remove_implementation_photos)) if @form.remove_implementation_photos.any?
      end
      return files_list_to_remove
    end

    # private method
    #
    # Parameters:
    #
    # project - Project
    #
    # builds various attachments for Project
    #
    # returns nothing
    def build_attachments
      if @form.add_documents.any?
        @form.add_documents.each do |file|
          @documents << Decidim::Attachment.new(
            title: { I18n.locale => file.original_filename },
            attached_to: @attached_to || documents_attached_to,
            file: file,
            # custom only for projects
            attachment_type: 'document'
          )
        end
      end

      if @form.add_more_documents.any?
        @form.add_more_documents.each do |file|
          @documents << Decidim::Attachment.new(
            title: { I18n.locale => file.original_filename },
            attached_to: @attached_to || documents_attached_to,
            file: file,
            # custom only for projects
            attachment_type: 'consent'
          )
        end
      end

      if @form.add_photos.any?
        @form.add_photos.each do |file|
          @documents << Decidim::Attachment.new(
            title: { I18n.locale => file.original_filename },
            attached_to: @attached_to || documents_attached_to,
            file: file,
            # custom only for projects
            attachment_type: 'endorsement'
          )
        end
      end
    end

    # private method
    #
    # checking if various attachments are valid
    #
    # returns Boolean
    def attachments_invalid?
      @documents.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each do |error|
          if document.attachment_type == 'document'
            @form.errors.add(:add_documents, error)
          elsif document.attachment_type == 'consent'
            @form.errors.add(:add_more_documents, error)
          elsif document.add_photos == 'endorsement'
            @form.errors.add(:add_documents, error)
          else
            @form.errors.add(:add_documents, error)
          end
        end

        return true
      end

      false
    end

    # private method
    #
    # creating attachments:
    # - document
    # - consent
    # - endorsement
    #
    # returns Boolean
    def create_attachments
      @documents.map! do |document|
        document.attached_to = documents_attached_to
        document.save!
        if document.attachment_type == 'document'
          @form.documents << document
        elsif document.attachment_type == 'consent'
          @form.more_documents << document
        elsif document.attachment_type == 'endorsement'
          @form.photos << document
        else
          @form.documents << document
        end

      end
    end

    # private method
    #
    # removing various attachments from project
    # - document
    # - consent
    # - endorsement
    #
    # returns nothing
    def document_cleanup!
      documents_attached_to.documents.each do |document|
        document.destroy! if @form.documents.map(&:id).exclude?(document.id) && document.attachment_type == 'document'
        document.destroy! if @form.more_documents.map(&:id).exclude?(document.id) && document.attachment_type == 'consent'
        document.destroy! if @form.photos.map(&:id).exclude?(document.id) && document.attachment_type == 'endorsement'
      end

      documents_attached_to.reload
      documents_attached_to.instance_variable_set(:@documents, nil)
    end

    # private method
    #
    # determine if there are attachments to add
    #
    # returns Boolean
    def process_attachments?
      @form.add_documents.any? || @form.add_more_documents.any? || @form.add_photos.any?
    end

    # private method
    #
    # checks to what object files are to be attached
    # if no object was passed to @attached_to variable
    # method looks for Organization Object
    #
    # returns Object
    def documents_attached_to
      return @attached_to if @attached_to.present?
      return form.current_organization if form.respond_to?(:current_organization)

      form.current_component.organization if form.respond_to?(:current_component)
    end
  end
end
