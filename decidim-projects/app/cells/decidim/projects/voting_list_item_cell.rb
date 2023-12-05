# frozen_string_literal: true

module Decidim::Projects
  class VotingListItemCell < Decidim::Projects::ProjectMCell
    include ActionView::Helpers::NumberHelper

    # public method
    #
    # renders show view
    def show
      render :show
    end

    # public method
    #
    # returns String - HTML code for the view with model data:
    #   <div class='scope-and-number'>
    #     ESOG_NUMBER
    #   </div>
    def esog_number
      content_tag 'div', class: 'scope-and-number' do
        model.esog_number
      end
    end

    # public method
    #
    # returns project short description
    def short_description 
      model.short_description 
    end

    def vote_for_project_url
      global = options[:project].is_district_project? ? "0" : "1"
      Decidim::EngineRouter.main_proxy(options[:project].component).votes_card_vote_path(options[:vote_card].voting_token, options[:project].id, global: global)
    end

    private

    def voting_number
      model.voting_number
    end

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
