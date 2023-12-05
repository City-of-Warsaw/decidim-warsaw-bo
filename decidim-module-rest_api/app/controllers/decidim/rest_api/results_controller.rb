# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class ResultsController < ApplicationController

    def show
      edition_year = params[:groupId]
      edition = Decidim::ParticipatoryProcess.published.find_by edition_year: edition_year

      render json: edition.scope_budgets.includes(:scope)
    end

    def region
      regionId = params[:regionId]
      region = Decidim::Scope.find regionId
      edition_year = params[:groupId]
      edition = Decidim::ParticipatoryProcess.published.find_by edition_year: edition_year

      render json: {
        regionId: regionId,
        regionName: region.name['pl'],
        budget: 0,
        winCost: 0,
        cardsAccepted: 0,
        projects: []
      }
    end
  end
end
