# frozen_string_literal: true

module Decidim
  module Projects
    # A class used to find potentially mutually exclusive projects
    # Projects are find in specific distance from each others
    # return Project scope
    class PotentiallyMutuallyExclusiveProjects

      RAD_PER_DEG  = Math::PI/180  # PI / 180
      RM           = 6371 * 1000   # Earth radius in kilometers * radius in meters
      MIN_DISTANCE = 100           # Minimum distance between projects location points in meters

      # project - is a project for which we look potentially mutually exclusive projects
      def initialize(project)
        @project = project
      end

      def query
        return Decidim::Projects::Project.none if project.locations.none?

        iteration = 0
        exclusive_projects_ids = []
        project.locations.each do |loc_id, location|
          loc1 = location_point_from(location)

          # check all projects for each location
          projects_from_process.each do |proj|
            proj.locations.each do |k, loc|
              iteration += 1
              loc2 = location_point_from(loc)
              exclusive_projects_ids << proj.id if distance(loc1, loc2).round(2) < MIN_DISTANCE
            end
          end
        end

        if exclusive_projects_ids.any?
          Decidim::Projects::Project.where(id: exclusive_projects_ids.uniq)
        else
          Decidim::Projects::Project.none
        end
      end

      private

      attr_reader :project

      # get projects from the same process for searching potentially mutually exclusive projects
      def projects_from_process
        @projects_from_process ||= Decidim::Projects::ProjectsForVoting.new(project.component).query
                                                                         .where.not(locations: nil)
                                                                         .where.not(id: project.id)
                                                                         .select(:id, :locations)
      end

      # Distance between 2 points
      # each point is an array fo ["lan", "lat"]
      # return FixNum in meters
      def distance(loc1, loc2)
        dlat_rad = (loc2[0] - loc1[0]) * RAD_PER_DEG # Delta, converted to rad
        dlon_rad = (loc2[1] - loc1[1]) * RAD_PER_DEG

        lat1_rad = loc1.map { |i| i * RAD_PER_DEG }.first
        lat2_rad = loc2.map { |i| i * RAD_PER_DEG }.first

        a        = Math.sin(dlat_rad / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
        c        = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

        RM * c # Delta in meters
      end

      def location_point_from(location)
        [location["lat"].to_f, location["lng"].to_f]
      end
    end
  end
end
