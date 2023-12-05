# frozen_string_literal: true

# A command with all the business logic when creating a static scope.
Decidim::Admin::CreateScope.class_eval do
  private

  # OVERWRITTEN DECIDIM METHOD
  # added custom attribute:
  # department - allows crating scope as belonging to Decidim::AdminExtended::Department instance
  def create_scope
    Decidim.traceability.create!(
      Decidim::Scope,
      form.current_user,
      {
        name: form.name,
        organization: form.organization,
        code: form.code,
        scope_type: form.scope_type,
        department: form.department,
        parent: @parent_scope,
        position: form.position
      },
      extra: {
        parent_name: @parent_scope.try(:name),
        scope_type_name: form.scope_type.try(:name)
      }
    )
  end
end