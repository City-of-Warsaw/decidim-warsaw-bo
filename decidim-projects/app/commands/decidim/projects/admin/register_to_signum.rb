# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to register projects into Signum at once.
      class RegisterToSignum < Rectify::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # component - The component that contains the projects.
        # user      - the Decidim::User that is accepting changes.
        # project_ids - the identifiers of the projects with the changes to be accepted.
        def initialize(component, user, project)
          @component = component
          @user = user
          @project = project
          @service = Decidim::SignumService.new
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if project was eegistered in Signum before.
        #
        # Returns nothing.
        def call
          return broadcast(:registered_already) if project.signum_znak_sprawy.present?

          urz_id = find_urz_id
          return broadcast(:invalid_login) if urz_id.blank?

          register_to_signum(urz_id)

          broadcast(:ok, project)
        end

        private

        attr_reader :component, :user, :project, :service

        def register_to_signum(urz_id)
          service.register_project_to_signum(urz_id: urz_id, project: project, user: user)
        end

        def find_urz_id
          service.find_user_in_signum(user)
        end
      end
    end
  end
end
