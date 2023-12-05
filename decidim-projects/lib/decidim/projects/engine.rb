# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Projects
    # This is the engine that runs on the public interface of projects.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Projects

      # defines engine routes here
      routes do
        resource :endorsement_list, only: [] do
          get :actual_edition, on: :member
        end
        resources :projects_wizard, only: [:new, :create, :edit, :update] do
          member do
            get :edit_draft
            patch :update_draft
            get :author
            patch :update_author_data
            get :preview
            get :confirmation
            post :publish
            put :withdraw
          end
        end
        resources :projects, only: [:show] do
          member do
            resource :coauthorship, only: [:edit, :update]
            post :send_private_message, controller: 'messages'
            get :map_details_data
          end
          resource :endorsement_list, only: :show
          resources :versions, only: [:show, :index]
          resources :posters, only: :show
          resources :appeals, except: [:index, :destroy] do
            member do
              get :publish
            end
          end
        end
        resources :projects_lists, path: 'projects', only: [:index]
        get 'realizations', controller: 'projects_lists'
        get 'results', controller: 'projects_lists', as: 'results'

        resources :votes_cards do
          member do
            get :district_projects
            get :filtered_projects
            patch :publish
            get :finish
          end
          resources :votes, only: [:index, :update]
        end

        root to: "projects_lists#index"
      end

      initializer "decidim_projects.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::Projects::Engine => '/'
        end

        Decidim::Core::Engine.routes.prepend do
          resources :coauthorship_acceptances, only: [:edit, :update]
        end

        Decidim::ParticipatoryProcesses::AdminEngine.routes.prepend do
          scope :participatory_processes do
            get ':slug/statistics' => '/decidim/projects/admin/statistics#index', as: :statistics_admin
            post ':slug/statistics' => '/decidim/projects/admin/statistics#update', as: :statistics_admin_update
            get ':slug/project_forms/edit' => '/decidim/projects/admin/project_forms#edit', as: :edit_project_form
            patch ':slug/project_form' => '/decidim/projects/admin/project_forms#update', as: :project_form

            get ':slug/voters_imports/new' => '/decidim/projects/admin/voters_imports#new', as: :new_voters_imports
            post ':slug/voters_imports' => '/decidim/projects/admin/voters_imports#create', as: :voters_imports

            get ':slug/poster_templates' => '/decidim/projects/admin/poster_templates#index', as: :poster_templates
            get ':slug/poster_templates/new' => '/decidim/projects/admin/poster_templates#new', as: :new_poster_template
            post ':slug/poster_templates' => '/decidim/projects/admin/poster_templates#create', as: :create_poster_template
            get ':slug/poster_templates/:id' => '/decidim/projects/admin/poster_templates#show', as: :poster_template
            get ':slug/poster_templates/:id/edit' => '/decidim/projects/admin/poster_templates#edit', as: :edit_poster_template
            patch ':slug/poster_templates/:id' => '/decidim/projects/admin/poster_templates#update', as: :update_poster_template
            delete ':slug/poster_templates/:id' => '/decidim/projects/admin/poster_templates#destroy', as: :destroy_poster_template
          end
        end
      end

      initializer "decidim.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.all_projects", scope: "decidim"),
                    '/projects',
                    position: 1,
                    active: is_active_link?(decidim_projects.projects_lists_path)
        end

        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.all_realizations", scope: "decidim"),
                    '/realizations',
                    position: 2,
                    active: is_active_link?(decidim_projects.realizations_path)
        end
      end

      initializer "decidim_projects.assets" do |app|
        app.config.assets.precompile += %w[decidim_projects_manifest.js decidim_projects_manifest.css
                                           admin/decidim_projects_manifest.js
                                           decidim/projects/jquery.mask.min.js
                                           decidim/projects/project_form.js
                                           universal_choose.js.es6 attachment_button.js.es6
                                           decidim/projects/budget_limits_handling.js decidim/projects/words-limit.js
                                           decidim/projects/autocomplete.min.js
                                           decidim/projects/leaflet-src.1.8.0.modCS.js
                                           decidim/projects/leaflet.legend.js
                                           decidim/projects/leaflet.markercluster.js
                                           decidim/projects/leaflet-gesture-handling.min.js
                                           decidim/projects/locations-map.js.erb
                                           decidim/projects/markers-map.js.erb
                                           decidim/projects/markers-map-voting.js.erb
                                           images/decidim/projects/images/abandoned-icon.png
                                           images/decidim/projects/images/finished-icon.png
                                           images/decidim/projects/images/in_progress-icon.png
                                           images/decidim/projects/images/blue-icon.png
                                           images/decidim/projects/images/green-icon.png
                                           images/decidim/projects/images/gray-icon.png
                                           images/decidim/projects/images/orange-icon.png
                                           images/decidim/projects/images/marker-icon.png
                                           images/decidim/projects/images/toggle-map-marker.png
                                           images/decidim/projects/admin/images/abandoned-icon.png
                                           images/decidim/projects/admin/images/finished-icon.png
                                           images/decidim/projects/admin/images/in_progress-icon.png
                                           images/decidim/projects/admin/images/blue-icon.png
                                           images/decidim/projects/admin/images/green-icon.png
                                           images/decidim/projects/admin/images/gray-icon.png
                                           images/decidim/projects/admin/images/orange-icon.png
                                           images/decidim/projects/admin/images/marker-icon.png
                                           images/decidim/projects/admin/images/toggle-map-marker.png
                                           images/decidim/projects/admin/images/info-graph.png
                                           images/decidim/projects/admin/images/info-graph-hollow.png
                                           images/decidim/projects/admin/images/vote-check.png
                                           decidim/projects/admin/formal_evaluation.js
                                           decidim/projects/admin/meritorical_evaluation.js
                                           decidim/projects/admin/reevaluation.js
                                           decidim/projects/admin/votes.js
                                           decidim/projects/voting_form.js
                                           ]
      end

      config.autoload_paths << File.join(
        Decidim::Projects::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::Projects::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      initializer "decidim_projects.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Projects::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Projects::Engine.root}/app/views")
      end
    end
  end
end
