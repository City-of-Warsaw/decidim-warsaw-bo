# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module CoreExtended
    # This is the engine that runs on the public interface of core_extended.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CoreExtended

      routes do
        namespace :account do
          resource :user_password #, only: :update

          resources :appeals
          resources :notes, except: :show
          resources :projects, only: [:index, :destroy] do
            post :duplicate, on: :member
          end
          resources :watched_projects, path: 'watched-projects', only: [:index, :destroy]
        end
      end

      initializer "decidim_core_extended.append_routes", after: :load_config_initializers do |_app|
        Decidim::Comments::Engine.routes.prepend do
          scope :comments do
            get ':id/hide' => 'comments#hide', as: :hide_comment
          end
        end

        Rails.application.routes.append do
          mount Decidim::CoreExtended::Engine => "/"
        end
      end

      initializer "decidim_core_extended.assets" do |app|
        app.config.assets.precompile += %w[decidim_core_extended_manifest.js decidim_core_extended_manifest.css
                                           decidim/core_extended/decidim-logo-black.png
                                           decidim/core_extended/step_01.svg decidim/core_extended/step_01active.svg
                                           decidim/core_extended/step_02.svg decidim/core_extended/step_02active.svg
                                           decidim/core_extended/step_03.svg decidim/core_extended/step_03active.svg
                                           decidim/core_extended/step_04.svg decidim/core_extended/step_04active.svg
                                           decidim/core_extended/step_05.svg decidim/core_extended/step_05active.svg
                                           decidim/core_extended/category_default.svg
                                           decidim/core_extended/syrenka-kolor.svg
                                           decidim/core_extended/attachment-icon.svg
                                           decidim/core_extended/download-icon.svg
                                           decidim/core_extended/delete-icon.svg
                                           decidim/core_extended/duplicate-icon.svg
                                           decidim/core_extended/edit-icon.svg
                                           decidim/core_extended/export-icon.svg
                                           decidim/core_extended/close-icon.svg
                                           decidim/core_extended/info-step-1.svg
                                           decidim/core_extended/info-step-2.svg
                                           decidim/core_extended/info-step-3.svg
                                           decidim/core_extended/info-step-4.svg
                                           decidim/core_extended/sample-photos/city-photo.jpg
                                           decidim/core_extended/sample-photos/family-photo.jpg
                                           decidim/core_extended/email.scss
                                         ]
      end

      config.autoload_paths << File.join(
        Decidim::CoreExtended::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::CoreExtended::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      # cells
	    initializer "decidim_core_extended.add_cells_view_paths" do
	       Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CoreExtended::Engine.root}/app/cells")
         Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CoreExtended::Engine.root}/app/views")
      end
    end
  end
end
