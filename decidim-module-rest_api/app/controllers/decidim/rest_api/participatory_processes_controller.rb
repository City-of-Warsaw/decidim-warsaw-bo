# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class ParticipatoryProcessesController < ApplicationController

    def_param_group :participatory_process do
      param :id, :number, desc: 'id of the requested participatory_process',
            description: 'id of the requested participatory_process',
            required: true
    end
    def_param_group :participatory_process_return do
      property :id, Integer, :desc => "Id"
      property :title, String, :desc => "Tytuł"
      property :edition_year, String, :desc => "Edycja"
    end

    api :GET, '/participatory_processes', "Lista edycji"
    returns array_of: :participatory_process_return, code: 200, desc: "a successful response"
    def index
      render json: collection
    end

    api :GET, '/participatory_processes/:id', "Szczegóły edycji"
    param_group :participatory_process
    returns :participatory_process_return, code: 200, desc: "a successful response"
    def show
      render json: collection.find(params[:id])
    end

    private

    def collection
      Decidim::ParticipatoryProcess.published.order(end_date: :asc)
    end
  end
end
