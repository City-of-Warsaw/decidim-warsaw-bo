# frozen_string_literal: true

module Decidim::Projects
  class ProjectListItemCell < Decidim::Projects::ProjectMCell
    include ActionView::Helpers::NumberHelper

    # public method
    #
    # renders show view
    def show
      render :show
    end

    # public method
    #
    # returns Integer - count of categories that are to be shown
    def categories_number
      3
    end

    private

    # private method
    #
    # gives an info if results data should be rendered
    #
    # returns Boolean
    def show_for_result?
      false
    end

    # private method
    #
    # returns String - model status that is the set as class for the HTML tag
    def status_class
      model.state
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
      I18n.t("decidim.projects.projects.content_blocks.slider.localized_in", localization: translated_attribute(model.scope.name))
    end

    # private method
    #
    # returns String - default color for the scope
    def scope_color
      '#1F72AE'
    end
  end
end
