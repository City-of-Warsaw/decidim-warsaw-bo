# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows to manage budget info positions, use and list groups for them, in admin panel
  class Admin::BudgetInfoPositionsController < Admin::ApplicationController
    layout "decidim/admin/pages"

    helper_method :budget_info_groups

    def index
      enforce_permission_to :update, :organization, organization: current_organization
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::BudgetInfoPositionForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::BudgetInfoPositionForm).from_params(params)

      Admin::CreateBudgetInfoPosition.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("budget_info_positions.create.success", scope: "decidim.admin_extended.admin")
          redirect_to budget_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("budget_info_positions.create.errors", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::BudgetInfoPositionForm).from_model(budget_info_position)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::BudgetInfoPositionForm).from_params(params)

      Admin::UpdateBudgetInfoPosition.call(budget_info_position, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("budget_info_positions.update.success", scope: "decidim.admin_extended.admin")
          redirect_to budget_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("budget_info_positions.update.errors", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      budget_info_position.destroy!
      flash[:notice] = I18n.t("budget_info_positions.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to budget_info_positions_path
    end

    private

    def budget_info_groups
      BudgetInfoGroup.sorted_by_weight
    end

    def budget_info_position
      @budget_info_position ||= BudgetInfoPosition.find_by(id: params[:id])
    end
  end
end
