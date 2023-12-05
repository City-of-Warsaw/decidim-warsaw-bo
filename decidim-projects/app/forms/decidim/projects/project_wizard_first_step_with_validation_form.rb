# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module Projects
    # A form object to create and update Projects.
    # This form is used on first step of creating projects wizard
    # and allows creating and updating project draft and moving to another step as it contains validations.
    class ProjectWizardFirstStepWithValidationForm < Decidim::Projects::ProjectWizardCreateStepForm
      mimic :project

      include Decidim::TranslatableAttributes
      include Decidim::AttachmentAttributes

      attribute :project_id, Integer

      # user data fields
      attribute :first_name, String
      attribute :last_name, String
      attribute :gender, String
      attribute :phone_number, String
      attribute :email, String
      attribute :coauthor_email_one, String
      attribute :coauthor_email_two, String

      validates :title, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 255 }
      validates :body, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 4000 }

      validates :short_description, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 500 }
      validates :universal_design_argumentation, presence: true, if: proc { |attrs| attrs[:universal_design] == false || attrs[:universal_design] == 'false' }, length: { maximum: 1000 }
      validates :justification_info, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 2000 }
      validates :localization_info, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 2000 }
      validates :localization_additional_info, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 2000 }
      validates :budget_value, presence: true, numericality: { greater_than_or_equal_to: 1 }

      validates :scope_id, presence: true
      validates :scope, presence: true
      validate :needs_attachments
      validate :categories_picked
      validate :recipients_picked

      validate :additional_fields

      def additional_fields
        return unless edition.project_customization
        return unless edition.project_customization.additional_attributes.present?

        edition.project_customization.additional_attributes[0].each do |k, v|
          if additional_data[k.to_sym].blank?
            errors.add(:"[additional_data][#{k.to_s}]", 'Należy wypełnić') if v[0]['required'] == '1'
          else
            errors.add(:"[additional_data][#{k.to_s}]", 'Musi być liczbą') if v[0]['type'] == 'number_field' && !additional_data[k.to_sym].to_i.is_a?(Integer)
          end
        end
      end

      # Public: sets Project
      def project
        @project ||= Decidim::Projects::Project.find_by(id: project_id)
      end

      def edition
        @edition ||= project&.participatory_space.presence || Decidim::ParticipatoryProcess.actual_edition
      end

      def value_limit
        edition.scope_budgets.find_by(decidim_scope_id: scope_id)&.max_proposal_budget_value
      end

      def categories_picked
        if category_ids_other.present? && custom_categories.blank?
          errors.add(:custom_categories, 'Należy wypełnić pole')
        elsif category_ids_other.blank? && custom_categories.present?
          errors.add(:custom_categories, "Należy oznaczyć checkbox 'Inna'")
        else
          return if assigned_categories.any?

          if custom_categories.blank?
            errors.add(:category_ids, '')
            errors.add(:custom_categories, 'Należy wybrać kategorię lub wpisać własną')
          end
        end
      end

      def recipients_picked
        if potential_recipient_ids_other.present? && custom_recipients.blank?
          errors.add(:custom_recipients, 'Należy wypełnić pole')
        elsif potential_recipient_ids_other.blank? && custom_recipients.present?
          errors.add(:custom_recipients, "Należy oznaczyć checkbox 'Inni'")
        else
          return if recipients.any?

          if custom_recipients.blank?
            errors.add(:recipient, '')
            errors.add(:custom_recipients, 'Należy wybrać odbiorców lub wpisać własnych')
          end
        end
      end

      def needs_attachments
        if project && add_endorsements.none? && project.endorsements.none?
          # for edition
          errors.add(:add_endorsements, :needs_to_be_attached)
        elsif project && add_endorsements.none? && project.endorsements.count <= remove_endorsements.size
          # for edition
          errors.add(:add_endorsements, 'Nie można usunąć wszystkich plików')
        elsif !project && add_endorsements.none?
          # for create
          errors.add(:add_endorsements, :needs_to_be_attached)
        end
      end

      def email_was_not_changed
        return if email.blank?

        errors.add(:email, :is_not_confirmed_email) if email != model.email
      end

      def budget_value_is_within_limit
        return if budget_value.blank?
        return unless scope_id

        if value_limit
          errors.add(:budget_value, :too_high) if budget_value.to_i > value_limit
        else
          errors.add(:budget_value, :too_high)
        end
      end

      def map_model(model)
        super

        # The scope attribute is with different key (decidim_scope_id), so it
        # has to be manually mapped.
        self.project_id = model.id
        self.title = model.title
        self.body = model.body
        self.scope_id = model.scope.id if model.scope
        self.category_ids = model.categories.map(&:id) if model.categories.any?
        self.potential_recipient_ids = model.recipients.map(&:id) if model.recipients.any?

        self.add_files = model.files if model.files.any?
        self.add_consent = model.consents if model.consents.any?
        self.add_endorsements = model.endorsements if model.endorsements.any?
      end

      # Finds the Scope from the given scope_id, uses participatory space scope if missing.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= @scope_id ? Decidim::Scope.find_by(id: @scope_id) : project.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the project
      def scope_id
        @scope_id || scope&.id
      end

      private

      # This method will add an error to the `attachment` fields only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        errors.add(:add_endorsements, :needs_to_be_reattached) if errors.any? && add_endorsements.any?
        errors.add(:add_consents, :needs_to_be_reattached) if errors.any? && add_consents.any?
        errors.add(:add_files, :needs_to_be_reattached) if errors.any? && add_files.any?
      end

      def ordered_hashtag_list(string)
        string.to_s.split.reject(&:blank?).uniq.sort_by(&:parameterize)
      end
    end
  end
end
