# frozen_string_literal: true

# OVERWRITTEN DECIDIM FORM
# This module includes helpers to show scopes in admin
Decidim::Admin::ScopesHelper.class_eval do
  # Public: A formatted collection of departments for a given organization to be used
  # in forms.
  # organization - Organization object
  # Returns an Array.
  def organization_departments(organization = current_organization)
    [Decidim::Admin::ScopesHelper::Option.new("", "-")] +
      Decidim::AdminExtended::Department.all.map do |department|
        Decidim::Admin::ScopesHelper::Option.new(department.id, translated_attribute(department.name))
      end
  end
end