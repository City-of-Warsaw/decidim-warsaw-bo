# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module AdminExtended
    # This is the engine that runs on the public interface of admin_extended.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AdminExtended

      routes do
        resources :statistics, only: :index
      end

      initializer "decidim_admin_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::AdminExtended::Engine => '/'
        end
      end

      initializer "decidim_admin_extended.assets" do |app|
        app.config.assets.precompile += %w[decidim_admin_extended_manifest.js
                                           decidim/admin/newsletters_decor.js
                                           decidim/admin_extended/application.js
                                           decidim_admin_extended_manifest.css]
      end

      initializer "decidim_admin_extended.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::AdminExtended::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::AdminExtended::Engine.root}/app/views")
      end
    end
  end
end
