# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to evaluation of the project.
    class RegisterToSignumJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(user, component, urz_id, project_ids)
        service = Decidim::SignumService.new
        projects(component, project_ids).each do |project|
          service.register_project_to_signum(urz_id: urz_id, project: project, user: user)
        end
      end

      # Private: fetch projects
      #
      # returns collection of projects
      def projects(component, project_ids)
        @projects ||= Decidim::Projects::ProjectsFromEdition.for(component)
                                                            .published
                                                            .where(signum_znak_sprawy: nil)
                                                            .where(id: project_ids)
      end
    end
  end
end
