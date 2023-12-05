# frozen_string_literal: true

module Decidim
  module Projects
    # Controller that show posters
    class PostersController < Decidim::Projects::ApplicationController
      helper Decidim::Projects::ApplicationHelper

      helper_method :project, :posters, :poster_template

      def show
        kit = IMGKit.new render_to_string, width: poster_template.width, height: poster_template.height, javascript_delay: 2000
        send_data kit.to_jpg, filename: "#{poster_template.title.parameterize}.jpg", type: 'image/jpg', disposition: 'attachment'
      end

      private

      def project
        @project ||= find_project
      end

      def find_project
        if current_user && current_user.ad_admin? && params[:project_id] == "0"
          return Decidim::Projects::Project.new(scope: Decidim::Scope.find_by(id: poster_template.sample_project_area),
                                                voting_number: poster_template.sample_project_number,
                                                title: poster_template.sample_title,
                                                esog_number: '123')
        end

        proj = Decidim::Projects::Project.published.not_hidden.find_by(id: params[:project_id])
        if !proj && current_user
          proj = Decidim::Projects::Project.from_author(current_user).find_by(id: params[:project_id])
        end
        proj
      end

      def poster_template
        Decidim::Projects::PosterTemplate.find_by(id: params[:id])
      end
    end
  end
end
