# frozen_string_literal: true

module Decidim::Projects
  class ProjectHighlightedListItemCell < Decidim::Projects::ProjectMCell
    include ActionView::Helpers::NumberHelper

    # public method
    #
    # renders show view
    def show
      render :show
    end

    private

    # private method
    #
    # returns String - HTML code for the view with model data:
    #   <div class='scope-and-number'>
    #     <span style='color: #000000'>SCOPE_TYPE_NAME</span>
    #     / ESOG_NUMBER
    #   </div>
    def scope_and_number
      content_tag 'div', class: 'scope-and-number' do
        (content_tag 'span', class: scope_color_class do
          translated_attribute scope&.scope_type&.name
        end) +
        " / #{model.esog_number}"
      end
    end

    # private method
    #
    # returns String - translation with model.edition_year as param
    def year_info
      I18n.t("decidim.projects.projects.content_blocks.slider.idea_for_edition_year", edition_year: model.edition_year)
    end

    # private method
    #
    # returns String - translation with translated scope name as param
    def localization_info
      I18n.t("decidim.projects.projects.content_blocks.slider.localized_in", localization: translated_attribute(scope&.name))
    end
  end
end
