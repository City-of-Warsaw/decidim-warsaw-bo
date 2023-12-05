# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update document.
      class DocumentForm < Form
        include ::Decidim::HasUploadValidations
        ROLES = %w[coordinators sub_coordinators verifiers editors]

        attribute :file
        attribute :folder_id, Integer
        attribute :user_roles, Array

        mimic :document

        validate :validate_file
        validates :file, presence: true, if: Proc.new { |form| form.create_form? }

        def map_model(model)
          super

          self.user_roles = model.map_roles
        end

        # return if form is used for create action or not
        def create_form?
          id.blank?
        end

        def available_roles
          ROLES.map do |role|
            [role.to_s, I18n.t(role, scope: 'activemodel.attributes.document')]
          end
        end

        def all_roles?
          (for_coordinators? && for_sub_coordinators? && for_verifiers? && for_editors?) ||
            (!for_coordinators? && !for_sub_coordinators? && !for_verifiers? && !for_editors?)
        end

        def for_coordinators?
          user_roles.include?('coordinators')
        end

        def for_sub_coordinators?
          user_roles.include?('sub_coordinators')
        end

        def for_verifiers?
          user_roles.include?('verifiers')
        end

        def for_editors?
          user_roles.include?('editors')
        end

        def validate_file
          dummy_document = Document.new(file: file)
          dummy_document.validate
          dummy_document.errors['file'].each do |err|
            errors.add(:file, err)
          end
        end
      end
    end
  end
end
