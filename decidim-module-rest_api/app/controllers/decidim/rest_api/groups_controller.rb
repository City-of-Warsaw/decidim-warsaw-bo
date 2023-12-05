# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class GroupsController < ApplicationController

    def index
      editions = Decidim::ParticipatoryProcess.published.order(end_date: :asc)

      render json: editions
    end
  end
end
