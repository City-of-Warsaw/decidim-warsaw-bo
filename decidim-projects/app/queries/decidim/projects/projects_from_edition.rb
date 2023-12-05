# frozen_string_literal: true

module Decidim
  module Projects
    # A class used to find the projects from edition
    class ProjectsFromEdition < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # projects_component - projects component
      def self.for(projects_component)
        new(projects_component).query
      end

      def initialize(component)
        @projects_component = component
      end

      def query
        Decidim::Projects::Project.where(decidim_component_id: projects_component.id)
      end

      private

      attr_reader :projects_component
    end
  end
end
