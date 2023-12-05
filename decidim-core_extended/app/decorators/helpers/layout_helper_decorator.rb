# frozen_string_literal: true

Decidim::LayoutHelper.module_eval do

  # Outputs an SVG-based icon for user account.
  #
  # name    - The String with the icon name.
  # Returns a String.
  def account_icon(name)
    content_tag :svg, { xmlns: "http://www.w3.org/2000/svg" } do
      content_tag :use, nil, role: "img", "href" => "#{asset_path("#{name}-icon.svg")}#icon", width: "100%", height: "100%"
    end
  end

  # Return active class for active menu in static pages
  # topic         - topic for header page
  # current_page  - actual page
  # Return String or nil
  def static_page_active?(topic, current_page)
    return if topic.pages.none? || !current_page&.topic

    'active' if topic.id == current_page.topic.id
  end

end