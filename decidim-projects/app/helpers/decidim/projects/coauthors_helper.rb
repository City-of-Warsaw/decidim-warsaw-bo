# frozen_string_literal: true

module Decidim
  module Projects
    # Simple helpers for coauthors data for projects view
    module CoauthorsHelper
      # show author name on project page
      def project_coauthors_list(project)
        coauthors = []
        project_coauthorships = project.coauthorships.where(coauthor: true).order(created_at: :asc)
        if project.coauthor1_data.present?
          coauthors << Decidim::CoauthorData.new(@project.coauthor1_data, project_coauthorships.first)
        end
        if project.coauthor2_data.present?
          coauthors << Decidim::CoauthorData.new(@project.coauthor2_data, project_coauthorships.second)
        end
        coauthors
      end
    end
  end
end
