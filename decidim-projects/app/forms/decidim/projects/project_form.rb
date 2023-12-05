# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module Projects
    # A form object to update Projects.
    # This form is used for publishing and editing already published project,
    # because it contains all of the projects validations.
    class ProjectForm < Decidim::Projects::ProjectWizardCreateStepForm
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

      # address fields
      attribute :street, String
      attribute :street_number, String
      attribute :flat_number, String
      attribute :zip_code, String
      attribute :city, String

      # agreements fields
      attribute :show_author_name, GraphQL::Types::Boolean
      attribute :inform_author_about_implementations, GraphQL::Types::Boolean
      attribute :email_on_notification, GraphQL::Types::Boolean

      validates :title, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 255 }
      validates :body, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 4000 }

      validates :short_description, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 500 }
      validates :universal_design_argumentation, presence: true, if: proc { |attrs| attrs[:universal_design] == false || attrs[:universal_design] == 'false' }, length: { maximum: 1000 }
      validates :justification_info, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 2000 }
      validates :localization_info, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 2000 }
      validates :localization_additional_info, obscenity: { message: "Nie może zawierać wulgaryzmów" }, length: { maximum: 2000 }
      validates :budget_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      validates :first_name, :last_name, presence: true
      validates :gender, inclusion: { in: ['male', 'female'] }
      validates :street, :street_number, :city, presence: true
      validates :zip_code, presence: true, format: { with: /\A[0-9]{2}-[0-9]{3}\z/ }

      validates :scope_id, presence: true
      validates :scope, presence: true
      validate :needs_attachments
      validate :categories_picked
      validate :recipients_picked

      def project
        @project ||= Decidim::Projects::Project.find_by(id: project_id)
      end

      def edition
        @edition ||= project.participatory_space
      end

      def value_limit
        edition.scope_budgets.find_by(decidim_scope_id: scope_id)&.max_proposal_budget_value
      end

      def categories_picked
        return if assigned_categories.any?

        if custom_categories.blank?
          errors.add(:category_ids, '')
          errors.add(:custom_categories, 'Należy wybrać kategorię lub wpisać własną')
        end
      end

      def recipients_picked
        return if recipients.any?

        if custom_recipients.blank?
          errors.add(:recipient, '')
          errors.add(:custom_recipients, 'Należy wybrać odbiorców lub wpisać własnych')
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
        self.add_consents = model.consents if model.consents.any?
        self.add_endorsements = model.endorsements if model.endorsements.any?

        # user data for validation
        # creator = model.creator_author
        self.first_name = model.first_name
        self.last_name = model.last_name
        self.gender = model.gender
        self.phone_number = model.phone_number
        self.email = model.email
        # address
        self.street = model.street
        self.street_number = model.street_number
        self.flat_number = model.flat_number
        self.zip_code = model.zip_code
        self.city = model.city
        # agreements
        self.show_author_name = model.show_author_name
        self.inform_author_about_implementations = model.inform_author_about_implementations
        self.email_on_notification = model.email_on_notification
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

      def geocoding_enabled?
        true
      end

      def geocoded?
        latitude.present? && longitude.present?
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
