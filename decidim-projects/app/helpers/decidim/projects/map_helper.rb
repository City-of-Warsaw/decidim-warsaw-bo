# frozen_string_literal: true

module Decidim
  module Projects
    # This helper include some methods for rendering projects dynamic maps.
    module MapHelper
      include Decidim::ApplicationHelper
      # Serialize a collection of geocoded projects to be used by the dynamic map component
      #
      # geocoded_projects - A collection of geocoded projects
      def projects_data_for_map(geocoded_projects)
        geocoded_projects.map do |project|
          project_data_for_map(project)
        end
      end

      def project_data_for_map(project)
        project
          .slice(:latitude, :longitude, :address)
          .merge(
            title: decidim_html_escape(project.title),
            body: html_truncate(decidim_sanitize(project.body), length: 100),
            icon: icon("projects", width: 40, height: 70, remove_icon_class: true),
            link: project_path(project)
          )
      end

      def project_preview_data_for_map(project)
        [
          project.slice(
            :latitude,
            :longitude,
            :address
          ).merge(
            icon: icon("projects", width: 40, height: 70, remove_icon_class: true),
            draggable: true
          )
        ]
      end

      def has_position?(project)
        return if project.address.blank?

        project.latitude.present? && project.longitude.present?
      end
    end
  end
end
