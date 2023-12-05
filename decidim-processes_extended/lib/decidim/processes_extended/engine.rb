# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ProcessesExtended
    # This is the engine that runs on the public interface of processes_extended.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ProcessesExtended

      routes do
        # Add engine routes here
        # resources :processes_extended
        # root to: "processes_extended#index"
      end

      initializer "decidim_processes_extended.assets" do |app|
        app.config.assets.precompile += %w[decidim_processes_extended_manifest.js decidim_processes_extended_manifest.css]
      end
    end
  end
end
