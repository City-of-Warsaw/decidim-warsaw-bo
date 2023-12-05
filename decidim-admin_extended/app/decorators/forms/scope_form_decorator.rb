# frozen_string_literal: true

# OVERWRITTEN DECIDIM FORM
# A form object to create or update scopes
# Class was provided with attribute for adding Department to Scope
Decidim::Admin::ScopeForm.class_eval do
  attribute :department_id, Integer
  attribute :position, Integer

  validates :department_id, presence: true

  # public method
  # returns Decidim::AdminExtended::Department via :department_id
  def department
    Decidim::AdminExtended::Department.find_by(id: department_id) if department_id
  end
end