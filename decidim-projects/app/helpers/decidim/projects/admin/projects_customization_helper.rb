# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Helper class for Projects in admin panel.
      module ProjectsCustomizationHelper

        def customizable_attribute_fields(el, f, scope = 'activemodel.attributes.project')
          label =  t(el, scope: scope)

          html = (content_tag :div, class: "card with-overflow" do
            (content_tag :div, class: "card-divider" do
              content_tag(:h2, label, class: "card-title")
            end.html_safe) +
            (content_tag :div, class: "card-section" do
              (f.text_field el, label: "#{label} - nazwa pola") +
              (content_tag :div, style: 'columns: 2' do
                (f.editor "#{el}_help_text", label: "#{label} - pole pomocy", lines: 8) +
                (f.editor "#{el}_hint", label: "#{label} - pole ukryte pod znakiem zapytania", lines: 8)
              end.html_safe)
            end.html_safe)
          end.html_safe)

          html
        end
      end
    end
  end
end
