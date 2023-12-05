# frozen_string_literal: true

Decidim::Admin::ScopesController.class_eval do

  # publicm overwritten
  # Change order of scopes
  def index
    enforce_permission_to :read, :scope
    @scopes = children_scopes.reorder(position: :asc)
  end

end
