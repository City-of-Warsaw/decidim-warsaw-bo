# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to register projects into Signum at once.
      class RegisterAllToSignum < Rectify::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # component - The component that contains the projects.
        # user      - the Decidim::User that is accepting changes.
        # project_ids - the identifiers of the projects with the changes to be accepted.
        def initialize(component, user, project_ids)
          @component = component
          @user = user
          @project_ids = project_ids
          @service = Decidim::SignumService.new
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are no projects.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless projects.any?

          urz_id = find_urz_id
          return broadcast(:invalid_login) if urz_id.blank?

          Decidim::Projects::RegisterToSignumJob.perform_later(user, component, urz_id, project_ids)

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :project_ids, :service

        def find_urz_id
          service.find_user_in_signum(user)
        end

        # Private: fetch projects
        #
        # returns collection of projects
        def projects
          @projects ||= Decidim::Projects::Project.published
                                                  .where(component: component)
                                                  .where(signum_znak_sprawy: nil)
                                                  .where(id: project_ids)
        end



      end
    end
  end
end
