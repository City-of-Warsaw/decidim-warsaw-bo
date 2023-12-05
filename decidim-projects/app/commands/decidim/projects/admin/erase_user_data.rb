# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to erase author & coauthors data from projects
      class EraseUserData < Rectify::Command
        # Public: Initializes the command.
        #
        # projects   - all available projects
        # user        - the Decidim::User that is erasing data
        def initialize(projects, user)
          @projects = projects
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          erase_projects

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :project_ids, :body

        def erase_projects
          projects_to_erase = @projects.where.not(state: Decidim::Projects::Project::POSSIBLE_STATES::SELECTED)
          projects_to_erase.update_all(author_data: user_data,
                                       coauthor1_data:user_data,
                                       coauthor2_data:user_data)
          projects_to_check = @projects.where(state: Decidim::Projects::Project::POSSIBLE_STATES::SELECTED)
          projects_to_check.each do |project|
            if project.author_data["inform_author_about_implementations"].present?
              project.update(author_data: user_data)
            end
            if project.coauthor1_data["inform_author_about_implementations"].present?
              project.update(coauthor1_data: user_data)
            end
            if project.coauthor2_data["inform_author_about_implementations"].present?
              project.update(coauthor2_data: user_data)
            end
          end
        end

        def user_data
          {
            first_name: "***",
            last_name: "***",
            phone_number: "***",
            gender: "***",
            street: "***",
            street_number: "***",
            flat_number: "***",
            zip_code: "***",
            city: "***",
            email: "***",
            # zgody
            show_author_name: false,
            inform_author_about_implementations: false
          }
        end

      end
    end
  end
end
