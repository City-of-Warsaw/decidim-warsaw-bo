# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class ProjectsController < ApplicationController


    def index
      limit = params[:limit].presence || 30
      offset = params[:offset].presence || 0
      edition_year = params[:groupId]
      edition = Decidim::ParticipatoryProcess.published.find_by edition_year: edition_year
      projects = Decidim::Projects::Project.where(decidim_component_id: edition.published_project_component&.id)
                                           .published
                                           .not_hidden
                                           .esog_sorted
      total = projects.count
      projects = projects.limit(limit)
                         .offset(offset)

      projects_json = projects.map{|p| Decidim::ProjectSerializer.new(p).as_json}

      # render json: projects, each_serializer: Decidim::ProjectSerializer
      render json: {
        data: projects_json,
        limit: limit,
        offset: offset,
        total: total
      }

      # render json: {
      #   data: ActiveModelSerializers::SerializableResource.new(items, each_serializer: Decidim::ProjectSerializer),
      #   message: ['Employee list fetched successfully'],
      #   status: 200,
      #   type: 'Success'
      # }
    end

    def show
      project = Decidim::Projects::Project.published.not_hidden.find params[:id]
      render json: project, serializer: Decidim::ProjectDetailsSerializer

      # render json: {
      #   data: ActiveModelSerializers::SerializableResource.new(item, serializer: Decidim::ProjectSerializer),
      #   message: ['Project fetched successfully'],
      #   status: 200,
      #   type: 'Success'
      # }
    end

    # status: Parametr określający poziom realizacji pobieranych projektów [bool]
    # 1 – Projekty zrealizowane
    # 0 – Projekty w trakcie realizacji
    def map
      # params[:status]
      # params[:southWestLongitude]
      # params[:southWestLatitude]
      # params[:northEastLongitude]
      # params[:northEastLatitude]

      projects = Decidim::Projects::Project.published.not_hidden
      projects = projects.implementations # chosen_for_implementation
      projects = projects.where("cast(main_location->>'lng' as float) > cast(? as float)", params[:southWestLongitude]) if params[:southWestLongitude].present?
      projects = projects.where("cast(main_location->>'lat' as float) > cast(? as float)", params[:southWestLatitude]) if params[:southWestLatitude].present?
      projects = projects.where("cast(main_location->>'lng' as float) < cast(? as float)", params[:northEastLongitude]) if params[:northEastLongitude].present?
      projects = projects.where("cast(main_location->>'lat' as float) < cast(? as float)", params[:northEastLatitude]) if params[:northEastLatitude].present?
      # projects = projects.limit(100)
      projects_json = projects.map{ |p| Decidim::ProjectMapSerializer.new(p).as_json }

      # "lat": 52.296932016087965,
      # "lng": 20.996761322021488

      render json: projects_json
    end

    private

    def collection
      Decidim::Projects::Project
        .where(decidim_component_id: published_component_ids)
        .published
        .not_hidden
        .esog_sorted
    end

    def published_component_ids
      @published_component_ids ||= Decidim::Component.joins(:published_process).pluck(:id)
    end
  end
end
