# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create Implementation in admin panel.
      class ImplementationForm < Decidim::Form
        include Decidim::AttachmentAttributes

        attribute :user, Decidim::User
        # project fields
        attribute :implementation_status, String
        attribute :producer_list, String
        attribute :budget_value, Integer
        attribute :implementation_on_main_site, Boolean
        attribute :implementation_on_main_site_slider, Boolean

        attachments_attribute :implementation_photos # zdjęcia
        attribute :remove_implementation_photos, [Integer]
        attribute :add_implementation_photos_alt

        # implementation fields
        attribute :project_id, Integer
        attribute :factual_budget_value, Integer
        attribute :implementation_body, String
        attribute :implementation_date, Decidim::Attributes::TimeWithZone

        validates :user, presence: true
        validates :project_id, presence: true
        validates :implementation_status, presence: true
        validates :budget_value, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: proc { |attrs| attrs.budget_value.present? }
        validates :factual_budget_value, numericality: { only_integer: true }, if: proc { |attrs| attrs.factual_budget_value.present? }

        validate :available_status_for_user
        validate :implementation_data

        def available_status_for_user
          errors.add(:implementation_status, 'Niedozwolona wartość') if implementation_status.to_i > 5
          errors.add(:implementation_status, 'Niedozwolona wartość') if implementation_status.to_i == 0 && !user.ad_admin?
        end

        def implementation_data
          return if implementation_body.present? && implementation_date.present?
          return if implementation_body.blank? && implementation_date.blank?

          errors.add(:implementation_date, 'W przypadku podania treści aktualizacji, należy także podać datę') if implementation_date.blank?
          errors.add(:implementation_body, 'W przypadku podania daty aktualizacji, należy także podać treść') if implementation_body.blank?
        end

        # Public: maps implementation fields into FormObject attributes
        def map_model(model)
          super
          # we mapping project model
          self.project_id = model.id
        end

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end
      end
    end
  end
end
