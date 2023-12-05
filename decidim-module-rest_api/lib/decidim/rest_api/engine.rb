# frozen_string_literal: true

require "rails"
require "decidim/core"
require "apipie-rails"

module Decidim
  module RestApi
    # This is the engine that runs on the public interface of rest_api.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::RestApi

      routes do
        # Add engine routes here
        scope '/rest-api' do
          resource :status, only: [:show]
          resources :groups, only: [:index]
          resources :projects, only: [:index, :show]
          get 'projectDetails', to: 'projects#show'
          get 'results', to: 'results#show'
          get 'map', to: 'projects#map'
          get 'regionResults', to: 'results#region'

          resources :districts, only: [:index]
          resources :scope_types, only: [:index]
          resources :participatory_processes, only: [:index, :show] do
            resources :projects, only: [:index]
          end
          resources :projects, only: [:show]
        end
        # Endpoint with no authentication for test only
        unless Rails.env.production?
          scope '/rest-api-no-auth', noauth: true do
            resource :status, only: [:show]
            resources :groups, only: [:index]
            resources :projects, only: [:index, :show]
            get 'projectDetails', to: 'projects#show'
            get 'results', to: 'results#show'
            get 'map', to: 'projects#map'
            get 'regionResults', to: 'results#region'

            resources :districts, only: [:index]
            resources :scope_types, only: [:index]
            resources :participatory_processes, only: [:index, :show] do
              resources :projects, only: [:index]
            end
            resources :projects, only: [:show]
          end
        end
      end

      initializer "decidim_rest_api.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::RestApi::Engine => "/"

          # routing for apipie gem
          apipie
        end
      end

      # with decidim update to 0.25.2, please uncomment below:
      # initializer "RestApi.webpacker.assets_path" do
      #   Decidim.register_assets_path File.expand_path("app/packs", root)
      # end

      initializer "decidim_rest_api.append_routes", after: :load_config_initializers do |_app|
        # config for apipie gem
        Apipie.configure do |config|
          config.app_name                = "Decidim BO"
          config.api_base_url            = "/rest-api"
          config.doc_base_url            = "/rest-api-doc"
          config.api_controllers_matcher = "#{Rails.root}/decidim-module-rest_api/app/controllers/decidim/**/*.rb"
          config.default_locale = 'pl'
          config.app_info = "REST API dla Decidim BO. Dostęp do API wymaga przekazania w nagłówku zapytania poprawnego tokenu X-Api-Key"
        end
      end

    end
  end
end
