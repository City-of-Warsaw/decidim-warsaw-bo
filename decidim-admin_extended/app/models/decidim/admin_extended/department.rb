# frozen_string_literal: true

module Decidim::AdminExtended
  # Department are used to provide:
  # mapping between Scopes and Users
  # mapping between Projects (via Scopes) and Users
  # establish permissions of projects delegations between each other
  class Department < ApplicationRecord
    enum department_type: { district: 10, general_municipal_unit: 20, office: 30, district_unit: 40 }, _suffix: 'type'

    has_many :department_delegations,
             class_name: "Decidim::AdminExtended::DepartmentDelegation",
             foreign_key: 'from_department_id',
             dependent: :delete_all
    has_many :departments,
             through: :department_delegations,
             class_name: "Decidim::AdminExtended::Department",
             source: :to_department
    has_many :project_department_assignments,
             class_name: "Decidim::Projects::ProjectDepartmentAssignment",
             foreign_key: :department_id,
             dependent: :destroy
    has_many :projects,
             through: :project_department_assignments,
             class_name: "Decidim::Projects::Project",
             source: :project

    scope :active,         -> { where(active: true) }
    scope :sorted_by_name, -> { order("name ASC") }
    scope :with_ad_name,   -> { where.not('decidim_admin_extended_departments.ad_name': nil) }

    validates :name, presence: true, uniqueness: true

    # public method
    # searches for Users that are ad_coordinators (or admins for 'cks')
    # with ad_role corresponding with department ad_name
    #
    # returns  ActiveRecord::Relation
    def coordinators
      return Decidim::User.none unless ad_name

      if ad_name == 'cks'
        Decidim::User.where(ad_role: ["decidim_bo_#{ad_name}_admin", "decidim_bo_#{ad_name}_koord"])
      else
        Decidim::User.where(ad_role: "decidim_bo_#{ad_name}_koord")
      end
    end

    # public method
    # searches for Users that are ad_sub_coordinators
    # with ad_role corresponding with department ad_name
    #
    # returns  ActiveRecord::Relation
    def sub_coordinators
      return Decidim::User.none unless ad_name

      Decidim::User.where(ad_role: "decidim_bo_#{ad_name}_podkoord")
    end

    # public method
    # searches for Users that are ad_verificators
    # with ad_role corresponding with department ad_name
    #
    # returns  ActiveRecord::Relation
    def verificators
      return Decidim::User.none unless ad_name

      Decidim::User.where(ad_role: "decidim_bo_#{ad_name}_weryf")
    end

    # public method
    # searches for Users that are ad_editors
    # with ad_role corresponding with department ad_name
    #
    # returns  ActiveRecord::Relation
    def editors
      return Decidim::User.none unless ad_name

      Decidim::User.where(ad_role: "decidim_bo_#{ad_name}_edytor")
    end

    # public method
    # For test only
    def create_delegations_to_departments
      # CKS
      cks = Decidim::AdminExtended::Department.find(2)
      Decidim::AdminExtended::Department.all.where.not(id: %w[2 1 205 206 222 221 225 231 228 232 234 235 236 237 238 253 183 184]).each do |dep|
        cks.department_delegations.create(to_department_id: dep.id)
      end

      bemowo = Decidim::AdminExtended::Department.find(1)
      %w[205 206 222 221 225 231 228 232 234 235 236 237 238 253 183 184].each do |id|
        dep = Decidim::AdminExtended::Department.find(id)
        bemowo.department_delegations.each do |delegation|
          d = dep.department_delegations.create(to_department_id: delegation.to_department_id)
          ap d.errors
        end
      end
    end
  end
end
