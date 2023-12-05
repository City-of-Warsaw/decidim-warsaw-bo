# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update departments.
      class DepartmentForm < Form

        attribute :name, String
        attribute :ad_name, String
        attribute :department_ids, [Integer]
        attribute :allow_returning_projects, Boolean
        attribute :active, Boolean
        attribute :department_type, String

        mimic :department

        validates :name, presence: true
        validate :name_is_unique
        validate :ad_name_is_unique_if_present
        validate :ad_name_is_present_if_active

        # alias organization current_organization

        # check if name is uniq
        def name_is_unique
          return if name.blank?

          record = Decidim::AdminExtended::Department.find_by(name: name)
          errors.add(:name, 'zostało już zajęte') if record && record.id != id
        end

        def ad_name_is_unique_if_present
          return if ad_name.blank?

          record = Decidim::AdminExtended::Department.find_by(ad_name: ad_name)
          errors.add(:ad_name, 'zostało już zajęte') if record && record.id != id
        end

        # requires ad_name if department is active
        def ad_name_is_present_if_active
          return if !active? || ad_name.present?

          errors.add(:ad_name, 'nie może być puste') if ad_name.blank?
        end

        def department_types
          [
            ["Dzielnica", :district],
            ["Jednostka ogólnomiejska", :general_municipal_unit],
            ["Biuro", :office],
            ["Jednostka dzielnicowa", :district_unit]
          ]
        end
      end
    end
  end
end
