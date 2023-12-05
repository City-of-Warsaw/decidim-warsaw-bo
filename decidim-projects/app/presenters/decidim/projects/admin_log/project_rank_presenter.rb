# frozen_string_literal: true

module Decidim
  module Projects
    module AdminLog
      # This class holds the logic to present a `Decidim::Projects::Project`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ProjectRankPresenter.new(action_log, view_helpers).present
      class ProjectRankPresenter < Decidim::Log::BasePresenter
        private

        # Private: returns presenter of the resource
        def resource_presenter
          @resource_presenter ||= Decidim::Projects::Log::ResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        def i18n_params
          {
            user_name: user_presenter.present,
            resource_name: resource_presenter.try(:present),
            space_name: space_presenter.present,
            scope_name: Decidim::Scope.find(action_log.decidim_scope_id).name["pl"]
          }
        end

        # Private: method returns translation for the given action
        def action_string
          case action
          when "ranking_list_index", "export_ranking_list","publish_ranking_list"
            # admin actions
            "decidim.projects.admin_log.project_rank.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
