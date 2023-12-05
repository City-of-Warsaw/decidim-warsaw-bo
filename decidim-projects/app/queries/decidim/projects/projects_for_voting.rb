# frozen_string_literal: true

module Decidim
  module Projects
    # A class used to find the projects for voting in edition
    class ProjectsForVoting < Rectify::Query
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
        ProjectsFromEdition.for(projects_component).chosen_for_voting
      end

      private

      attr_reader :projects_component
    end
  end
end
