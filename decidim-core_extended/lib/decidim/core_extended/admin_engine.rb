# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This is the engine that runs on the public interface of `CoreExtended`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CoreExtended::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :core_extended do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "core_extended#index"
      end

      def load_seed
        nil
      end
    end
  end
end
