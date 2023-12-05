# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class ScopeTypesController < ApplicationController

    api :GET, '/scope_types', "Lista typów dzielnic"
    returns :code => 200, :desc => "a successful response" do
      property :id, Integer, :desc => "Id"
      property :name, String, :desc => "Nazwa"
    end
    def index
      items = Decidim::ScopeType.all
      render json: items
    end
  end
end
