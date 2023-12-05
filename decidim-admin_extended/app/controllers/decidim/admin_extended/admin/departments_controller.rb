# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows managing all Departments (dictionary) at the admin panel.
  class Admin::DepartmentsController < Decidim::AdminExtended::Admin::ApplicationController
    layout "decidim/admin/settings"

    helper_method :departments

    def index
      enforce_permission_to :update, :organization, organization: current_organization
      render 'index'
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::DepartmentForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::DepartmentForm).from_params(params)

      Decidim::AdminExtended::Admin::CreateDepartment.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("departments.create.success", scope: "decidim.admin")
          redirect_to departments_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("departments.create.error", scope: "decidim.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::DepartmentForm).from_model(department)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::DepartmentForm).from_params(params)

      Decidim::AdminExtended::Admin::UpdateDepartment.call(department, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("departments.update.success", scope: "decidim.admin")
          redirect_to departments_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("departments.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      department.destroy!

      flash[:notice] = I18n.t("departments.destroy.success", scope: "decidim.admin")

      redirect_to departments_path
    end

    private

    # Private: returns Object - Department
    def department
      @department ||= departments.find params[:id]
    end

    def departments
      Department.sorted_by_name
    end
  end
end
