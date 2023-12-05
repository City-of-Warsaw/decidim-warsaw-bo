# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    module Admin
      # Controller that allows generating endorsement list for project
      class EndorsementListsSettingsController < Decidim::ProcessesExtended::Admin::ApplicationController
        include Decidim::FormFactory
        layout "layouts/decidim/admin/participatory_process"

        helper_method :current_participatory_process, :endorsement_list_setting, :current_participatory_space

        def index
          enforce_permission_to :index, :endorsement_list_setting
        end

        def edit
          enforce_permission_to :edit, :endorsement_list_setting
          @form = form(Decidim::ProcessesExtended::Admin::EndorsementListSettingForm).from_model(endorsement_list_setting)

        end

        def update
          enforce_permission_to :update, :endorsement_list_setting
          @form = form(Decidim::ProcessesExtended::Admin::EndorsementListSettingForm).from_params(params)
          Decidim::ProcessesExtended::Admin::UpdateEndorsementListSetting.call(endorsement_list_setting, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("success", scope: "decidim.admin.endorsement_list.update")
              redirect_to decidim_admin_participatory_processes.endorsement_list_setting_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("errors", scope: "decidim.admin.endorsement_list.update")
              render :edit
            end
          end
        end

        private
        def endorsement_list_setting
          current_participatory_process.endorsement_list_setting
        end

      end
    end
  end
end
