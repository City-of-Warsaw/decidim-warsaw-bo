# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to send messages about
      # implementation updates for many projects at once.
      class SendImplementationMessages < Rectify::Command
        # Public: Initializes the command.
        #
        # component   - The component that contains the answers.
        # user        - the Decidim::User that is publishing the answers.
        # project_ids - the identifiers of the projects with the answers to be published.
        # body        - String - message body
        def initialize(component, user, project_ids, body)
          @component = component
          @user = user
          @project_ids = project_ids
          @body = body
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if body is empty
        # - :invalid if there are no projects.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if body.blank?
          return broadcast(:invalid) unless projects.any?

          projects.each do |project|
            transaction do
              send_message(project)
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :project_ids, :body

        # Private: fetch projects
        #
        # returns collection of published projects
        def projects
          @projects ||= Decidim::Projects::Project
                        .published
                        .where(component: component)
                        .where(id: project_ids)
        end

        # Private: send message to project authors
        #
        # returns nothing
        def send_message(project)
          project.authors.each do |author|
            Decidim::Projects::ImplementationJob.perform_later(project, author, body)
          end
        end
      end
    end
  end
end
