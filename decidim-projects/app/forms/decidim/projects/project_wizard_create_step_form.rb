# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to create Projects.
    # This form is used on first step of creating projects wizard
    # and allows creating project draft as it contains only validations that check data type.
    class ProjectWizardCreateStepForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :project

      include Decidim::AttachmentAttributes

      attribute :title, String
      attribute :body, Decidim::Attributes::CleanString

      attribute :locations_json, Hash
      attribute :scope_id, Integer
      attribute :attachment, Decidim::AttachmentForm

      attachments_attribute :internal_documents
      attachments_attribute :endorsements # endorsements (old photos)
      attachments_attribute :consents     # Consent for the use of the work (old more_documents)
      attachments_attribute :files        # attachments (old documents)
      attribute :remove_internal_documents, [Integer]
      attribute :remove_endorsements, [Integer]
      attribute :remove_consents, [Integer]
      attribute :remove_files, [Integer]

      # custom fields
      attribute :short_description, String
      attribute :universal_design, Virtus::Attribute::Boolean
      attribute :universal_design_argumentation, String
      attribute :justification_info, String
      attribute :category_ids, Array[Integer]
      attribute :category_ids_other, String
      attribute :custom_categories, String
      attribute :potential_recipient_ids, Array[Integer]
      attribute :potential_recipient_ids_other, String
      attribute :custom_recipients, String
      attribute :localization_info, String
      attribute :localization_additional_info, String
      attribute :budget_value, Integer

      # dynamic fields
      attribute :additional_data

      validates :budget_value, numericality: { only_integer: true, less_than_or_equal_to: 1000000000 }, if: proc { |attrs| attrs.budget_value.present? }

      alias component current_component

      def potential_recipient_checked?(recipient)
        potential_recipient_ids.member?(recipient)
      end

      def potential_recipients
        @recipients ||= Decidim::AdminExtended::Recipient.active.sorted_by_name
      end

      def recipients
        ids = potential_recipient_ids.reject { |e| e.to_s.empty? }
        Decidim::AdminExtended::Recipient.active.where(id: ids)
      end


      def geocoding_enabled?
        true
      end

      def scopes
        Decidim::Projects::DistrictScopes.new.query_all_sorted
      end

      def scopes_mapped
        scopes.map do |s|
          if s.citywide?
            [translated_attribute(s.name), s.id, data: { limit: edition.limit_for_scope(s) }]
          else
            ["#{translated_attribute(s&.scope_type&.name).presence || 'Dzielnicowy'} / #{translated_attribute(s.name)}", s.id, data: { limit: edition.limit_for_scope(s) }]
          end
        end
      end

      def scope
        scopes.find_by(id: scope_id)
      end

      def available_categories
        @categories ||= current_organization.areas.active
      end

      def category_checked?(cat)
        self.category_ids.member?(cat)
      end

      def assigned_categories
        ids = category_ids.reject { |e| e.to_s.empty? }
        Decidim::Area.active.where(id: ids)
      end

      def edition
        @edition ||= component.participatory_space
      end

      def map_model(model)
        super

        self.title = model.title
        self.body = model.body
        # due to different key (decidim_scope_id) of scopes attribute it has to be manually mapped
        self.scope_id = model.scope.id if model.scope
        self.potential_recipient_ids = model.recipients.map(&:id) if model.recipients.any?
        self.potential_recipient_ids_other = 'other' if model.custom_recipients.present?
        self.category_ids = model.categories.map(&:id) if model.categories.any?
        self.category_ids_other = 'other' if model.custom_categories.present?
        self.locations_json = model.locations.to_json
        self.additional_data = model.additional_data
      end

      def geocoded?
        latitude.present? && longitude.present?
      end

      def locations_data
        JSON.parse(locations_json)
      end
    end
  end
end
