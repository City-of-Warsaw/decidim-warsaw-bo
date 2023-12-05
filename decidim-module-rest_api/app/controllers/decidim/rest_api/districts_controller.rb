# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class DistrictsController < ApplicationController

    api :GET, '/districts', "Lista dzielnic"
    returns :code => 200, :desc => "a successful response" do
      property :id, Integer, :desc => "Id"
      property :name, String, :desc => "Nazwa"
      property :scope_type_id, String, :desc => "Typ dzielnicy"
    end
    def index
      items = Decidim::Scope.includes(:scope_type)
      render json: items
    end
  end
end
