# frozen_string_literal: true

module Decidim::AdminExtended
  # Department can delegate project to another department, if it is on delegation list
  # DepartmentDelegation are used to provide a many-to-many association
  # between different Departments
  class DepartmentDelegation < ApplicationRecord
    belongs_to :from_department,
               class_name: "Decidim::AdminExtended::Department",
               foreign_key: :from_department_id
    belongs_to :to_department,
               class_name: "Decidim::AdminExtended::Department",
               foreign_key: :to_department_id
  end
end
