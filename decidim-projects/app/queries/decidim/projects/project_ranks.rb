# frozen_string_literal: true

module Decidim
  module Projects
    # A class used to find the project ranks edition.
    class ProjectRanks < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # component - projects edition
      def self.for(component)
        new(component).query
      end

      def initialize(component)
        @component = component
      end

      def query
        projects = Decidim::Projects::ProjectsForVoting.new(component).query
        Decidim::Projects::ProjectRank.where(project_id: projects.map(&:id))
      end

      private

      attr_reader :component
    end
  end
end
