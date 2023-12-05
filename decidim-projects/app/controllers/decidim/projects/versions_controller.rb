# frozen_string_literal: true

module Decidim
  module Projects
    # Exposes Projects versions so users can see how a Project
    # has been updated through time.
    class VersionsController < Decidim::Projects::ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::ResourceVersionsConcern

      helper_method :item_name

      # Public: resource
      #
      # returns object - presenter of a project
      def versioned_resource
        @versioned_resource ||=
          if params[:project_id]
            present(Project.where(component: current_component).find(params[:project_id]))
          end
      end

      def item_name
        versioned_resource.model_name.singular_route_key.to_sym
      end
    end
  end
end
