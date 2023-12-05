# frozen_string_literal: true

module Decidim
  module CoreExtended
    module Account
      class WatchedProjectsController < Decidim::CoreExtended::ApplicationController
        include Decidim::UserProfile
        helper Decidim::ResourceHelper
        layout 'decidim/core_extended/user_profile'

        helper_method :projects

        def index; end

        def destroy
          @form = form(Decidim::FollowForm).from_params(params)
          enforce_permission_to :delete, :follow, follow: @form.follow

          DeleteFollow.call(@form, current_user) do
            on(:ok) do
              redirect_to account_watched_projects_path, notice: 'Projekt został usunięty z obserwowanych'
            end

            on(:invalid) do
              redirect_to account_watched_projects_path, error: I18n.t("follows.destroy.error", scope: "decidim")
            end
          end
        end

        private

        def projects
          @projects ||= begin
                          projects_ids = current_user.following_follows.where(decidim_followable_type: 'Decidim::Projects::Project').pluck(:decidim_followable_id)
                          Decidim::Projects::Project.where(id: projects_ids)
                          # Decidim::Projects::Project.where(id: projects_ids).implementations.where(implementation_status: [1, 2, 3, 4])
                        end
        end

        def projects_component
          @projects_component ||= latest_edition.published_project_component
        end
      end
    end
  end
end