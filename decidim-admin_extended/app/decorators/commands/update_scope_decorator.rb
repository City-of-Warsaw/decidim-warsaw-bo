# frozen_string_literal: true

# A command with all the business logic when updating a scope.
Decidim::Admin::UpdateScope.class_eval do
  private

  # OVERWRITTEN DECIDIM METHOD
  # added custom attribute:
  # department - allows crating scope as belonging to Decidim::AdminExtended::Department instance
  def attributes
    {
      name: form.name,
      code: scope_code,
      department: form.department,
      scope_type: form.scope_type,
      position: form.position
    }
  end

  def scope_code
    @scope.code == 'om' ? @scope.code : form.code
  end
end