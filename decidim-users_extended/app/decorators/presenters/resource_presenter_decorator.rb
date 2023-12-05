# frozen_string_literal: true

Decidim::Log::ResourcePresenter.class_eval do
  private

  # Private: Presents the resource of the action. If the resource and the
  # space are found in the database, it links to it. Otherwise it only
  # shows the resource name.
  #
  # Returns an HTML-safe String.
  def present_resource
    return h.content_tag(:span, present_resource_name) if resource.is_a?(Decidim::User)

    if resource.blank? || resource_path.blank?
      h.content_tag(:span, present_resource_name, class: 'logs__log__resource')
    else
      h.link_to(present_resource_name, resource_path, class: 'logs__log__resource')
    end
  end
end
