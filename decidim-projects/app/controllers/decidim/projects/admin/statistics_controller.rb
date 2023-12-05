# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing projects in admin panel.
      class StatisticsController < Decidim::Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin

        def index
          @scopes = get_scopes
          @selected_scope = select_scope(params[:scope_code])
          @form = form(Decidim::Projects::Admin::StatisticForm).from_params(
            participatory_process_id: participatory_process.id,
            scope_id: @selected_scope.id,
            number_of_project_voters_0_18: statistics_find&.number_of_project_voters_0_18,
            number_of_project_voters_19_24: statistics_find&.number_of_project_voters_19_24,
            number_of_project_voters_25_34: statistics_find&.number_of_project_voters_25_34,
            number_of_project_voters_35_44: statistics_find&.number_of_project_voters_35_44,
            number_of_project_voters_45_64: statistics_find&.number_of_project_voters_45_64,
            number_of_project_voters_65_100: statistics_find&.number_of_project_voters_65_100
          )
        end

        def update
          @form = form(Decidim::Projects::Admin::StatisticForm).from_params(params)
          selected_scope = Decidim::Scope.find_by_id(@form.scope_id)

          Admin::SaveStatisticsParticipatoryProcess.call(@form) do
            on(:ok) do |project|
              flash[:notice] = I18n.t("statistics_manage.success", scope: "decidim.projects.admin")
              redirect_to decidim_admin_participatory_processes.statistics_admin_path(current_participatory_space,scope_code: selected_scope.code)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("statistics_manage.invalid", scope: "decidim.projects.admin")
              redirect_to decidim_admin_participatory_processes.statistics_admin_path(current_participatory_space,scope_code: selected_scope.code)
            end
          end
        end

        private

        def get_scopes
          Decidim::Scope.where(scope_type_id: [1, 2]).order(:position)
        end

        def statistics_find
          Decidim::Projects::StatisticsParticipatoryProcess
            .find_by(scope: @selected_scope, participatory_process: participatory_process)
        end

        def participatory_process
          @participatory_process ||= Decidim::ParticipatoryProcess.find_by(slug: params[:slug])
        end

        def select_scope(code)
          if code.nil?
            Decidim::Scope.find_by(name: { "pl": "Ogólnomiejski" })
          else
            Decidim::Scope.find_by(code: code)
          end
        end
      end
    end
  end
end
