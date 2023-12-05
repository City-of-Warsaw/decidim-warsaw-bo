# frozen_string_literal: true

module Decidim::AdminExtended
  class Admin::ContactInfoPositionsController < Admin::ApplicationController
    layout "decidim/admin/pages"

    helper_method :contact_info_groups

    def index
      enforce_permission_to :update, :organization, organization: current_organization
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoPositionForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoPositionForm).from_params(params)

      Admin::CreateContactInfoPosition.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("contact_info_positions.create.success", scope: "decidim.admin_extended.admin")
          redirect_to contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("contact_info_positions.create.errors", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoPositionForm).from_model(contact_info_position)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoPositionForm).from_params(params)

      Admin::UpdateContactInfoPosition.call(contact_info_position, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("contact_info_positions.update.success", scope: "decidim.admin_extended.admin")
          redirect_to contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("contact_info_positions.update.errors", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      contact_info_position.destroy!
      flash[:notice] = I18n.t("contact_info_positions.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to contact_info_positions_path
    end

    private

    def contact_info_groups
      ContactInfoGroup.sorted_by_weight
    end

    def contact_info_position
      @contact_info_position ||= ContactInfoPosition.find_by(id: params[:id])
    end
  end
end
