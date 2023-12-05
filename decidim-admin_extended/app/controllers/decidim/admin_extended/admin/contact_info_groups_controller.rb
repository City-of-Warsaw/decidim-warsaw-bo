# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows to manage contact info groups, which store positions in admin panel
  class Admin::ContactInfoGroupsController < Admin::ApplicationController
    layout "decidim/admin/pages"

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoGroupForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoGroupForm).from_params(params)
    
      Admin::CreateContactInfoGroup.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("contact_info_groups.create.success", scope: "decidim.admin_extended.admin")
          redirect_to contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("contact_info_groups.create.errors", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoGroupForm).from_model(contact_info_group)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::ContactInfoGroupForm).from_params(params)

      Admin::UpdateContactInfoGroup.call(contact_info_group, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("contact_info_groups.update.success", scope: "decidim.admin_extended.admin")
          redirect_to contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("contact_info_groups.update.errors", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      contact_info_group.destroy!
      flash[:notice] = I18n.t("contact_info_groups.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to contact_info_positions_path
    end

    private

    def contact_info_group
      @contact_info_group ||= ContactInfoGroup.find_by(id: params[:id])
    end
  end
end
